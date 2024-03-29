package gg.climb.fifthdrake.dbhandling

import java.net.URL
import java.util
import java.util.concurrent.TimeUnit

import scala.collection.JavaConversions._
import gg.climb.fifthdrake.lolobjects.RiotId
import gg.climb.fifthdrake.lolobjects.esports.{Player, Role, Team}
import gg.climb.fifthdrake.lolobjects.game.state._
import gg.climb.fifthdrake.lolobjects.game.{GameData, MetaData}
import gg.climb.fifthdrake.reasoning._
import gg.climb.fifthdrake.{Game, Time, Timeline}
import org.bson.BsonValue
import org.joda.time.DateTime
import org.mongodb.scala.bson.collection.immutable.Document
import org.mongodb.scala.bson.conversions.Bson
import org.mongodb.scala.model.Filters._
import org.mongodb.scala.{MongoClient, MongoDatabase}

import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.duration.Duration
import scala.concurrent.{Await, Future}

class MongoDbHandler(mongoClient: MongoClient) {

  private val TIMEOUT = Duration(5, TimeUnit.SECONDS)
  private val database: MongoDatabase = mongoClient.getDatabase("league_analytics")

  def getAllGames: Future[Seq[MetaData]] = getSeq("lcs_game_identifiers", None, buildMetadata)

  def getGidsByMatchup(team1: Team, team2: Team): Future[Seq[MetaData]] = {
    val condition1: Bson = and(equal("team1", team1.acronym), equal("team2", team2.acronym))
    val condition2: Bson = and(equal("team1", team2.acronym), equal("team2", team1.acronym))
    val filter = or(condition1, condition2)
    getSeq("lcs_game_identifiers", Some(filter), buildMetadata)
  }

  def getGidByRiotId(riotId: RiotId[Game]): Future[Option[MetaData]] = {
    val filter: Bson = equal("gameKey", riotId.id.toInt)
    getOne("lcs_game_identifiers", Some(filter), buildMetadata)
  }

  def getGIDsByTeam(team: Team): Future[Seq[MetaData]] = getGIDsByTeamAcronym(team.acronym)

  def getGIDsByTeamAcronym(teamName: String): Future[Seq[MetaData]] = {
    val filter: Bson = or(equal("team1", teamName), equal("team2", teamName))
    getSeq("lcs_game_identifiers", Some(filter), buildMetadata)
  }

  def getGIDsByTime(time: DateTime): Future[Seq[MetaData]] = {
    val filter: Bson = gt("gameDate", time.getMillis)
    getSeq("lcs_game_identifiers", Some(filter), buildMetadata)
  }

  def getCompleteGame(gameKey: RiotId[Game]): Future[Seq[GameState]] =
    getSeq("game_" + gameKey.id, None, parseGameState)

  /**
    * @param gameKey The riot id of the game
    * @param begin   - start of time window
    * @param end     - end of time window
    * @return List[GameState]
    */
  def getGameWindow(gameKey: RiotId[Game],
                    begin: Time,
                    end: Time): Future[Seq[GameState]] = {
    val filter = and(gte("t", begin.toMillis), lte("t", end.toMillis))
    getSeq("game_" + gameKey.id, Some(filter), parseGameState)
  }

  private def getSeq[A](collection: String,
                filter: Option[Bson],
                transform: Document => Option[A]): Future[Seq[A]] = {
    getFilteredCollection(collection, filter).toFuture().map(_.flatMap(transform(_)))
  }

  private def getFilteredCollection(collName: String, filter: Option[Bson]) = {
    val collection = database.getCollection(collName)
    filter match {
      case None => collection.find()
      case Some(f) => collection.find(f)
    }
  }

  private def buildMetadata(data: Document): Option[MetaData] = {
    for {
      team1 <- data.get("team1").map(_.asString().getValue)
      team2 <- data.get("team2").map(_.asString().getValue)
      time <- data.get("gameDate").map(_.asInt64().getValue).map(new DateTime(_))
      id <- data.get("gameKey").map(_.asInt32().getValue).map(x => new RiotId[GameData](x.toString))
      (patch, url, season, duration) <- Await.result(getMetaDataForGame(id), TIMEOUT)
    } yield {
      new MetaData(team1, team2, time, id, patch, url, season, duration)
    }
  }

  private def getMetaDataForGame(gameKey: RiotId[GameData])
  : Future[Option[(String, URL, Int, Time)]] =
    getOne("metadata", Some(equal("gameId", gameKey.id.toInt)), parseMetaData)

  private def getOne[A](collection: String,
                filter: Option[Bson],
                transform: Document => Option[A]): Future[Option[A]] = {
    getFilteredCollection(collection, filter).first()
    .toFuture()
    .map(_.headOption.flatMap(transform))
  }

  private def parseMetaData(data: Document): Option[(String, URL, Int, Time)] = {
    for {
      url <- data.get("youtubeURL")
        .flatMap(Option(_))
        .map(b => {
          if (b.isNull) { "https://www.youtube.com" }
          else { b.asString().getValue }
        })
        .map(new URL(_))
      patch <- data.get("gameVersion").map(_.asString().getValue)
      seasonId <- data.get("seasonId").map(_.asInt32().getValue)
      duration <- data.get("gameDuration").map(_.asInt32().getValue)
    } yield {
      (patch, url, seasonId, Duration(duration * 1000, TimeUnit.MILLISECONDS))
    }
  }

  private def parseGameState(doc: Document): Option[GameState] = {
    for {
      time <- doc.get("t")
              .map(_.asInt32().getValue)
              .map(millis => Duration(millis, TimeUnit.MILLISECONDS))
      teamStats <- doc.get("teamStats").map(x => Document(x.asDocument()))
      redTeamStats <- teamStats.get(Red.riotId.id).map(x => Document(x.asDocument()))
      blueTeamStats <- teamStats.get(Blue.riotId.id).map(x => Document(x.asDocument()))
      playerStats <- doc.get("playerStats").map(x => Document(x.asDocument()))
      blue <- parseGameData(blueTeamStats, playerStats, Blue)
      red <- parseGameData(redTeamStats, playerStats, Red)
    } yield new GameState(time, red, blue)
  }

  private def parseGameData(teamStats: Document,
                             playerStats: Document,
                             side: Side): Option[(TeamState, Set[PlayerState])] = {
    for {
      barons <- teamStats.get("baronsKilled").map(_.asInt32().getValue)
      dragons <- teamStats.get("dragonsKilled").map(_.asInt32().getValue)
      turrets <- teamStats.get("towersKilled").map(_.asInt32().getValue)
      states: Set[PlayerState] = playerStats.filter(_._2.asDocument().getInt32("teamId")
        .getValue.toString == side.riotId.id)
               .flatMap({ case (_, value) =>
                 parsePlayerState(Document(value.asDocument()))
                        }).toSet
    } yield (new TeamState(barons, dragons, turrets), states)
  }

  private def parsePlayerState(playerStat: Document): Option[PlayerState] = {
    for {
      playerId <- playerStat.get("playerId").map(_.asString().getValue).map(new RiotId[Player](_))
      championState <- parseChampionState(playerStat)
      location <- parseLocationData(playerStat)
      kills <- playerStat.get("kills").map(_.asInt32().getValue)
      deaths <- playerStat.get("deaths").map(_.asInt32().getValue)
      assists <- playerStat.get("assists").map(_.asInt32().getValue)
      currentGold <- playerStat.get("cg").map(_.asInt32().getValue)
      totalGold <- playerStat.get("tg").map(_.asInt32().getValue)
      participantId <- playerStat.get("participantId").map(_.asInt32().getValue)
    } yield new PlayerState(
      id = playerId,
      championState = championState,
      location = location,
      kills = kills,
      deaths = deaths,
      assists = assists,
      currentGold = currentGold,
      totalGold = totalGold,
      participantId = participantId
    )
  }

  private def parseLocationData(doc: Document): Option[LocationData] = {
    for {
      x <- doc.get("x").map(_.asInt32().getValue)
      y <- doc.get("y").map(_.asInt32().getValue)
    } yield new LocationData(x, y, 1.0)
  }

  private def parseChampionState(doc: Document): Option[ChampionState] = {
    for {
      hp <- doc.get("h").map(_.asInt32().getValue)
      hpMax <- doc.get("maxHealth").map(_.asInt32().getValue)
      power <- doc.get("p").map(_.asInt32().getValue)
      powerMax <- doc.get("maxPower").map(_.asInt32().getValue)
      xp <- doc.get("xp").map(_.asInt32().getValue)
      name <- doc.get("championName").map(_.asString().getValue)
    } yield new ChampionState(
      hp = hp,
      power = power,
      xp = xp,
      name = name,
      powerMax = powerMax,
      hpMax = hpMax
    )
  }

  def getTimelineForGame(gameKey : RiotId[Timeline]): Future[Option[Seq[GameEvent]]] =
    getOne("timelines", Some(equal("gameId", gameKey.id.toInt)), parseEventFrames)

  private def parseEventFrames(doc : Document) : Option[Seq[GameEvent]] = {
    for {
      events: util.List[BsonValue] <- doc.get("frames").map(_.asArray().getValues)
    } yield events.flatMap { bson: BsonValue =>
        parseSingleFrame(Document(bson.asDocument()))
    }.flatten
  }

  private def parseSingleFrame(doc : Document) : Option[Seq[GameEvent]] = {
    for {
      events: util.List[BsonValue] <- doc.get("events").map(_.asArray().getValues)
    } yield events.flatMap { bson: BsonValue =>
      val eventDoc = Document(bson.asDocument())
      val eventType = eventDoc.get("type").map(_.asString().getValue).getOrElse("")
      eventType match {
        case "BUILDING_KILL" => parseBuildingKill(eventDoc)
        case "ELITE_MONSTER_KILL" =>
          val monsterType = eventDoc.get("monsterType").map(_.asString().getValue).getOrElse("")
          monsterType match {
            case "DRAGON" => parseDragonKill(eventDoc)
            case "BARON_NASHOR" => parseBaronKill(eventDoc)
            case _ => None
          }
        case _ => None
      }
    }
  }

  private def parseBaronKill(doc : Document) : Option[BaronKill] = {
    for {
      locationDoc: Document <- doc.get("position").map(x => Document(x.asDocument()))
      killerId <- doc.get("killerId").map(_.asInt32().getValue)
      location <- parseLocationData(locationDoc)
      timestamp <- doc.get("timestamp").map(_.asInt32().getValue)
        .map(millis => Duration(millis, TimeUnit.MILLISECONDS))
    } yield {
      BaronKill(location, timestamp, new RiotId[(Side, Role)](killerId.toString))
    }
  }

  private def parseDragonKill(doc : Document) : Option[DragonKill] = {
    for {
      dragTypeStr <- doc.get("monsterSubType").map(_.asString().getValue)
      killerId <- doc.get("killerId").map(_.asInt32().getValue)
      locationDoc: Document <- doc.get("position").map(x => Document(x.asDocument()))
      location <- parseLocationData(locationDoc)
      timestamp <- doc.get("timestamp").map(_.asInt32().getValue)
        .map(millis => Duration(millis, TimeUnit.MILLISECONDS))
    } yield {
      val dragType = dragTypeStr match {
        case "AIR_DRAGON" => AirDragon()
        case "EARTH_DRAGON" => EarthDragon()
        case "ELDER_DRAGON" => ElderDragon()
        case "FIRE_DRAGON" => FireDragon()
        case "WATER_DRAGON" => WaterDragon()
      }
      DragonKill(location, dragType, timestamp, new RiotId[(Side, Role)](killerId.toString))
    }
  }

  private def parseBuildingKill(doc: Document) : Option[BuildingKill] = {
    for {
      laneStr <- doc.get("laneType").map(_.asString().getValue)
      towerTypeStr <- doc.get("towerType").map(_.asString().getValue)
      killingTeam <- doc.get("teamId").map(_.asInt32().getValue)
      buildingTypeStr <- doc.get("buildingType").map(_.asString().getValue)
      killerId <- doc.get("teamId").map(_.asInt32().getValue)
      locationDoc: Document <- doc.get("position").map(x => Document(x.asDocument()))
      location <- parseLocationData(locationDoc)
      timestamp <- doc.get("timestamp").map(_.asInt32().getValue)
        .map(millis => Duration(millis, TimeUnit.MILLISECONDS))
    } yield {
      val building = buildingTypeStr match {
        case "INHIBITOR_BUILDING" => Inhibitor()
        case "TOWER_BUILDING" =>
          towerTypeStr match {
            case "OUTER_TURRET" => OuterTurret()
            case "INNER_TURRET" => InnerTurret()
            case "BASE_TURRET" => BaseTurret()
            case "NEXUS_TURRET" => NexusTurret()
          }
      }
      val lane = laneStr match {
        case "TOP_LANE" => Top()
        case "MID_LANE" => Middle()
        case "BOT_LANE" => Bottom()
      }
      val turretColor = killingTeam.toString match {
        case Red.riotId.id => Blue
        case Blue.riotId.id => Red
      }
      BuildingKill(location, building, lane, turretColor, timestamp, new RiotId[(Side, Role)](killerId.toString))
    }
  }
}
