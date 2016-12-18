package gg.climb.fifthdrake.controllers

import java.util.concurrent.TimeUnit

import gg.climb.fifthdrake.dbhandling.DataAccessHandler
import gg.climb.fifthdrake.lolobjects.{InternalId, RiotId}
import gg.climb.fifthdrake.lolobjects.esports.Player
import gg.climb.fifthdrake.lolobjects.game.state.{Blue, PlayerState, Red, TeamState}
import gg.climb.fifthdrake.lolobjects.game.{GameData, InGameTeam, MetaData}
import gg.climb.fifthdrake.lolobjects.tagging.{Category, Tag}
import gg.climb.fifthdrake.{Game, Time, TimeMonoid}
import gg.climb.ramenx.Behavior
import play.api.libs.json.{JsArray, JsValue, Json, Writes, _}
import play.api.mvc.{Action, _}

import scala.collection.Map
import scala.concurrent.duration.Duration

class GameDataController(dbh: DataAccessHandler) extends Controller {

  def xpRequiredForLevel(level: Int): Int =
    if (level > 0 && level <= 18) {
      10 * (level - 1) * (18 + 5 * level)
    }
    else {
      throw
        new IllegalArgumentException(s"Level `$level' is not a possible level in League of Legends")
    }

  def getCurrentLevel(xp: Int): Int =
    if (xp > 0 && xp <= 18360) {
      ((Math.sqrt(2 * xp + 529) - 13) / 10).toInt
    }
    else {
      throw new IllegalArgumentException(s"Cannot have `$xp' xp")
    }

  def loadDashboard(gameKey: String): Action[AnyContent] = Action { request =>
    Ok(views.html.gameDashboard(request.host, gameKey))
  }

  def loadChampion(name: String): Action[AnyContent] = Action {
    val result = for {
      champ <- dbh.getChampion(name)
    } yield {
        Ok(
          Json.obj(
            "championName" -> champ.name,
            "championKey" -> champ.key,
            "championImage" -> champ.image.full
          )
        )
      }
    result.getOrElse(InternalServerError(s"Could not find champion $name"))
  }

  // scalastyle:off method.length
  def loadGameData(gameKey: String): Action[AnyContent] = Action {
    dbh.getGame(new RiotId[Game](gameKey)) match {
      case Some(game@(metadata, _)) =>
        implicit def behaviorWrites[A]
        (implicit writer: Writes[A])
        : Writes[Behavior[Time, A]] =
          new Writes[Behavior[Time, A]] {
            override def writes(behavior: Behavior[Time, A]): JsValue = JsArray(
              behavior
                .sampledBy(Duration.Zero, Duration(1, TimeUnit.SECONDS), metadata.gameDuration)
                .map(writer.writes)
                .getAll
                .map(_._2)
            )
          }

        implicit val teamStateWrite = new Writes[TeamState] {
          override def writes(teamState: TeamState): JsValue = Json.obj(
            "barons" -> teamState.barons,
            "dragons" -> teamState.dragons,
            "turrets" -> teamState.turrets
          )
        }

        implicit val playerStateWrite = new Writes[PlayerState] {
          override def writes(playerState: PlayerState): JsValue = Json.obj(
            "position" -> Json.obj(
              "x" -> playerState.location.x,
              "y" -> playerState.location.y
            ),
            "championState" -> Json.obj(
              "hp" -> playerState.championState.hp,
              "mp" -> playerState.championState.mp,
              "xp" -> playerState.championState.xp
            ))
        }

        def playerStateToJson(p: (Player, Behavior[Time, PlayerState])): JsValue = p match {
          case (player, states) => Json.obj(
            "id" -> player.id.id.toString,
            "side" -> states(Duration.Zero).sideColor.name,
            "role" -> player.role.name,
            "ign" -> player.ign,
            "championName" -> states(Duration.Zero).championState.name,
            "championImage" -> {
              val champImg = for {
                champion <- dbh.getChampion(states(Duration.Zero).championState.name)
              } yield controllers.routes.Assets.versioned(s"champion/${champion.image.full}").url
              champImg.getOrElse[String](controllers.routes.Assets.versioned("champion/unknown.png").url)
            },
            "playerStates" -> Json.toJson(states)
          )
        }

        implicit val inGameTeamWrites = new Writes[InGameTeam] {
          override def writes(o: InGameTeam): JsValue = Json.obj(
            "teamStates" -> Json.toJson(o.teamStates),
            "players" -> Json.toJson(o.playerStates.toList.map(playerStateToJson))
          )
        }

        implicit val metaDataWrites = new Writes[MetaData] {
          override def writes(o: MetaData): JsValue = Json.obj(
            "gameLength" -> o.gameDuration.toSeconds,
            "blueTeamName" -> o.blueTeamName,
            "redTeamName" -> o.redTeamName
          )

        }

        implicit val gameDataWrites = new Writes[GameData] {
          override def writes(o: GameData): JsValue = Json.obj(
            "blueTeam" -> Json.toJson(o.teams(Blue)),
            "redTeam" -> Json.toJson(o.teams(Red))
          )
        }

        implicit val gameWrites = new Writes[Game] {
          override def writes(o: (MetaData, GameData)): JsValue = o match {
            case (metaData, data) => Json.obj(
              "metadata" -> Json.toJson(metaData),
              "data" -> Json.toJson(data)
            )
          }
        }

        Ok(Json.toJson(game))
      case None =>
        NotFound
    }

  }
  // scalastyle:on method.length

  def getTags(gameKey: String): Action[AnyContent] = Action {
    Ok(loadTagData(gameKey))
  }
  private def loadTagData(gameKey: String): JsValue = {
    val tags = dbh.getTags(new RiotId[Game](gameKey))
    implicit val tagWrites = new Writes[Tag] {
      def writes(tag: Tag): JsObject = Json.obj(
        "id" -> tag.id.getOrElse(new InternalId[Tag]("")).id,
        "title" -> tag.title,
        "description" -> tag.description,
        "category" -> tag.category.name,
        "timestamp" -> tag.timestamp.toSeconds,
        "players" -> Json.toJson(tag.players.map(_.ign))
      )
    }
    Json.toJson(tags)
  }
  /**
    * Request body MultiFormData should resemble:
    * Map(
    *  "gameKey" -> "10"
    *  "title" -> "gank occurred top lane"
    *  "description" -> "Top laner ganked by roaming support and jungler"
    *  "category" -> "gank"
    *  "timestamp" -> 1234  //measured in seconds
    *  "relevantPlayerIgns" -> JsArray("Hauntzer", "Meteos", "Impact")
    *  "allplayerIgns" -> JSObject // contains all players
    *                              // Uses key value pair: (playerIgn -> playerId)
    * )
    * @return Ok if successful, otherwise BadRequest
    */
  def saveTag(): Action[AnyContent] = Action { request =>
    val body: AnyContent = request.body
    body.asJson.map{ jsonValue =>
      val data = jsonValue.as[JsObject].value
      val gameKey = data("gameKey").as[String]
      val title = data("title").as[String]
      val description = data("description").as[String]
      val category = data("category").as[String]
      val timeStamp = data("timestamp").as[Int]
      val allPlayers: Map[String, JsValue] = data("allPlayerData").as[JsObject].value
      val players = data("relevantPlayerIgns").as[JsArray].value.map{ jsVal =>
        val ign = jsVal.as[String]
        if(!allPlayers.contains(ign))
          BadRequest("Player ign not found in current game!")
        ign
      }.map{ign =>
        dbh.getPlayer(new InternalId[Player](allPlayers(ign).as[String]))
      }.toSet
      dbh.insertTag(new Tag(new RiotId[Game](gameKey), title, description,
        new Category(category), Duration(timeStamp, TimeUnit.SECONDS), players))
      Ok(loadTagData(gameKey))
    }.getOrElse{
      BadRequest("Failed to insert tag")
    }
  }

  def deleteTag(): Action[AnyContent] = Action { request =>
    val body: AnyContent = request.body
    body.asJson.map{ jsonValue =>
      val data = jsonValue.as[JsObject].value
      val tagId = data("id").as[String]
      dbh.deleteTag(new InternalId[Tag](tagId))
      Ok(Json.obj("id" -> tagId))
    }.getOrElse{
      BadRequest("Failed to delete tag")
    }
    Ok("hello world")
  }
}

