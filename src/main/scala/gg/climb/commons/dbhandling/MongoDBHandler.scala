package gg.climb.commons.dbhandling
import java.net.URL
import java.util.concurrent.TimeUnit

import gg.climb.lolobjects.RiotId
import gg.climb.lolobjects.esports.{Player, Role, Team}
import gg.climb.lolobjects.game.state._
import gg.climb.lolobjects.game.{Game, GameIdentifier, LocationData, MetaData}
import org.joda.time.DateTime
import org.mongodb.scala.bson.BsonNull
import org.mongodb.scala.bson.collection.immutable.Document
import org.mongodb.scala.bson.conversions.Bson
import org.mongodb.scala.model.Filters._
import org.mongodb.scala.{FindObservable, MongoClient, Observable}

import scala.collection.JavaConversions._
import scala.concurrent.Await
import scala.concurrent.duration.Duration

class MongoDBHandler(){

  val mongoClient: MongoClient = MongoClient("mongodb://localhost")
  val names: Observable[String] = mongoClient.listDatabaseNames()
  val database = mongoClient.getDatabase("league_analytics")
	val RED = 100
	val BLUE = 200

	/*********************************************************************************************************************
	********************************************* Querying Team/Players **************************************************
	*********************************************************************************************************************/
	def getAllTeams(): List[Team]= {
		val ob: Observable[Document] = database.getCollection("teams").find()
		val docs: Seq[Document] = results[Document](ob)
		docs.toList.map(doc => getTeam(doc))
	}

  private def getTeam(data : Document): Team = {
    val id = RiotId[Team](data.getOrElse("id", BsonNull()).asInt32.getValue.toString)
    val name = data.getOrElse("name", BsonNull()).asString.getValue
    val acronym = data.getOrElse("acronym", BsonNull()).asString.getValue
    val players: List[Player] = data.getOrElse("players", BsonNull()).asArray.getValues.map(
      player => {
        getPlayer(RiotId[Player](player.asInt32().getValue.toString))
      }
    ).filter(player => player != null).toList
    Team(id, name, acronym, players)
  }

  def getPlayer(riotId : RiotId[Player]) : Player = {
    val ob: Observable[Document] = database.getCollection("players").find(equal("id", riotId.id.toInt)).first()
    val data: Document = first(ob)
    if(data == null)
      return null
    val ign = data.getOrElse("name", BsonNull()).asString.getValue
    val role = Role.interpret(data.getOrElse("position", BsonNull()).asString.getValue)
    val teamId = data.getOrElse("teamSlug", BsonNull()).asString.getValue
    Player(riotId, ign, role, teamId)
  }

	/*********************************************************************************************************************
	********************************************* Querying Game Meta-Data ************************************************
	*********************************************************************************************************************/

  def getMetaDataForGame(gameKey: RiotId[Game]): MetaData = {
    val filter = equal("gameId", gameKey.id.toInt)
    val ob: Observable[Document] = database.getCollection("metadata").find(filter)
    val docs: Seq[Document] = results[Document](ob)
    buildMetaData(docs.toList(0))
  }
  def getAllMetaData(): List[MetaData] = {
		val ob: FindObservable[Document] = database.getCollection("metadata").find()
		val docs: Seq[Document] = results[Document](ob)
		docs.toList.map(data => buildMetaData(data))
	}

  private def buildMetaData(data: Document): MetaData = {
    val url = new URL(data.getOrElse("youtubeURL", BsonNull()).asString.getValue)
    val patch = data.getOrElse("gameVersion", BsonNull()).asString.getValue
    val seasonId = data.getOrElse("seasonId", BsonNull()).asInt32.getValue
    MetaData(patch, url, seasonId)
  }

 /**********************************************************************************************************************
  ******************************************* Querying Game Identifiers ************************************************
  *********************************************************************************************************************/
  /**
    * Each document contains the teams playing, gameKey, tournamnentRealmID and gameDate
    *
    * @return List[GameIdentifier]
    */
	def getAllGIDs(): List[GameIdentifier] ={
		val ob: FindObservable[Document] = database.getCollection("lcs_game_identifiers").find()
		val docs: Seq[Document] = results[Document](ob)
		docs.toList.map(data=> {
			buildGID(data)
		})
	}

  /**
    * If team1 and team2 are playing,
    *
    * @param team1
    * @param team2
    * @return List[Document] Game Identifiers with the given matchup
    */
	def getGIDsByMatchup(team1 : Team, team2: Team): List[GameIdentifier] = {
		val condition1: Bson = and(equal("team1", team1.acronym), equal("team2", team2.acronym))
		val condition2: Bson = and(equal("team1", team2.acronym), equal("team2", team1.acronym))
		val filter = or(condition1, condition2)
		val ob: FindObservable[Document] = database.getCollection("lcs_game_identifiers").find(filter)
		val docs: Seq[Document] = results[Document](ob)
		docs.toList.map(data => buildGID(data))
	}

	def getGIDsByTeam(team : Team): List[GameIdentifier] = getGIDsByTeamAcronym(team.acronym)

	def getGIDsByTeamAcronym(teamName : String): List[GameIdentifier] = {
		val filter: Bson = or(equal("team1", teamName), equal("team2", teamName))
		val ob: FindObservable[Document] = database.getCollection("lcs_game_identifiers").find(filter)
		val docs: Seq[Document] = results[Document](ob)
		docs.toList.map(data => buildGID(data))
	}
	def getGIDsByTime(time: DateTime): List[GameIdentifier] = {
		val filter: Bson = gt("gameDate", time.getMillis)
		val ob: FindObservable[Document] = database.getCollection("lcs_game_identifiers").find(filter)
		val docs: Seq[Document] = results[Document](ob)
		docs.toList.map(data => buildGID(data))
	}

	private def buildGID(data: Document): GameIdentifier = {
		val team1 = data.getOrElse("team1", BsonNull()).asString.getValue
		val team2 = data.getOrElse("team2", BsonNull()).asString.getValue
		val time = data.getOrElse("gameDate", BsonNull()).asInt64.getValue
		val id = RiotId[Game](data.getOrElse("gameKey", BsonNull()).asInt32.getValue.toString)
    val realm = data.getOrElse("realm", BsonNull()).asString.getValue
		GameIdentifier(team1,team2, new DateTime(time), id, getMetaDataForGame(id))
	}

 /**********************************************************************************************************************
  ********************************************* Querying GameState Data ************************************************
  *********************************************************************************************************************/

  /**
    * @param gameKey
    * @return List[GameState]
    */
	def getCompleteGame(gameKey : RiotId[Game]): List[GameState] = {
		val ob: FindObservable[Document] = database.getCollection("game_" + gameKey.id.toInt).find()
		val docs = results[Document](ob)
		docs.map(doc => getGameState(doc)).toList
	}

	private def getGameState(doc :Document) : GameState = {
		val time = Duration(doc.getOrElse("t", BsonNull()).asInt32().getValue,TimeUnit.MILLISECONDS)

		val teamStats = Document(doc.getOrElse("teamStats", BsonNull()).asDocument)
		val redTeamStats = Document(teamStats.getOrElse("100", BsonNull()).asDocument)
		val blueTeamStats = Document(teamStats.getOrElse("200", BsonNull()).asDocument)
		val playerStats = Document(doc.getOrElse("playerStats", BsonNull()).asDocument)

		val blue = getTeamState(redTeamStats, playerStats, RED)
		val red = getTeamState(blueTeamStats, playerStats, BLUE)
		GameState(time, red, blue)
	}

	private def getTeamState(teamStats : Document, playerStats: Document, side : Int) : TeamState = {
		val barons = teamStats.getOrElse("baronsKilled", BsonNull()).asInt32.getValue
		val dragons = teamStats.getOrElse("dragonsKilled", BsonNull()).asInt32.getValue
		val turrets = teamStats.getOrElse("towersKilled", BsonNull()).asInt32.getValue

		val states = playerStats.keySet
			.filter(key => playerStats.getOrElse(key, BsonNull()).asDocument.getInt32("teamId").getValue == side)
			.map(key => getPlayerState(Document(playerStats.getOrElse(key, BsonNull()).asDocument), side)).toList
		TeamState(states, barons, dragons, turrets)
	}

	private def getPlayerState(playerStat : Document, side: Int) : PlayerState = {
		val playerId = RiotId[Player](playerStat.getOrElse("playerId", BsonNull()).asString.getValue)
		val player = getPlayer(playerId)
		val championState = getChampionState(playerStat)
	  val location = getLocationData(playerStat)
		var color = SideColor.BLUE
		side match {
			case RED => color = SideColor.RED
			case BLUE => color = SideColor.BLUE
			case _ => throw new IllegalArgumentException("side must be 100 or 200 but intead was: " + side)
		}
		PlayerState(player, championState, location, color)
	}

	private def getLocationData(doc : Document): LocationData = {
		val x = doc.getOrElse("x", BsonNull()).asInt32.getValue
		val y = doc.getOrElse("y", BsonNull()).asInt32.getValue
		LocationData(x,y,1.0)
	}

	private def getChampionState(doc : Document) : ChampionState = {
		val hp = doc.getOrElse("h", BsonNull()).asInt32.getValue
		val mp = doc.getOrElse("p", BsonNull()).asInt32.getValue
		val xp = doc.getOrElse("xp", BsonNull()).asInt32.getValue
		val name = doc.getOrElse("championName", BsonNull()).asString.getValue
		ChampionState(hp, mp, xp, name)
	}

  /**
    * If observer returns nothing, we return null instead
    * @param ob
    * @return
    */
	private def first(ob : Observable[Document]): Document  = {
    try
      Await.result(ob.head(), Duration(5, TimeUnit.SECONDS))
    catch {
      case x: IllegalStateException => null
    }
  }
	private def results[T](ob : Observable[T]) : Seq[T] = Await.result(ob.toFuture(), Duration(5,TimeUnit.SECONDS))

}

object MongoDBHandler{
  def apply() = new MongoDBHandler()
  def main(args : Array[String]): Unit = {
		val dbh = MongoDBHandler()
	  val date = new DateTime(1467000000000L)
	  println(date)
    dbh.getAllTeams().map(team => println(team))
//	  val ob: FindObservable[Document] = dbh.database.getCollection("game_" + 1001710092).find()
//	  val docs: Seq[Document] = Await.result(ob.toFuture(), Duration(5,TimeUnit.SECONDS))
//		for(doc <- docs){
//			println(dbh.getGameState(doc))
//		}
  }
}
