package gg.climb.commons.dbhandling
import java.util.concurrent.TimeUnit

import gg.climb.lolobjects.RiotId
import gg.climb.lolobjects.esports.{Player, Role, Team}
import gg.climb.lolobjects.game.LocationData
import gg.climb.lolobjects.game.state.{ChampionState, GameState, PlayerState, TeamState}
import org.mongodb.scala.bson.BsonNull
import org.mongodb.scala.bson.collection.immutable.Document
import org.mongodb.scala.model.Filters._
import org.mongodb.scala.{FindObservable, MongoClient, Observable}

import scala.concurrent.Await
import scala.concurrent.duration.Duration

class MongoDBHandler(){
  val mongoClient: MongoClient = MongoClient("mongodb://localhost")
  val names: Observable[String] = mongoClient.listDatabaseNames()
  val database = mongoClient.getDatabase("league_analytics")


	def getCompleteGame(gameKey : Int): List[GameState] ={
		val ob: FindObservable[Document] = database.getCollection("game_" + gameKey).find()
		val docs = results[Document](ob)
		docs.map(doc => getGameState(doc)).toList
	}

	private def getGameState(doc :Document) : GameState = {
		val time = Duration(doc.getOrElse("t", BsonNull()).asInt32().getValue,TimeUnit.MILLISECONDS)

		val teamStats = Document(doc.getOrElse("teamStats", BsonNull()).asDocument)
		val redTeamStats = Document(teamStats.getOrElse("100", BsonNull()).asDocument)
		val blueTeamStats = Document(teamStats.getOrElse("200", BsonNull()).asDocument)
		val playerStats = Document(doc.getOrElse("playerStats", BsonNull()).asDocument)

		val blue = getTeamState(redTeamStats, playerStats, 100)
		val red = getTeamState(blueTeamStats, playerStats, 200)
		GameState(time, red, blue)
	}

	private def getTeamState(teamStats : Document, playerStats: Document, side : Int) : TeamState = {
		val barons = teamStats.getOrElse("baronsKilled", BsonNull()).asInt32.getValue
		val dragons = teamStats.getOrElse("dragonsKilled", BsonNull()).asInt32.getValue
		val turrets = teamStats.getOrElse("towersKilled", BsonNull()).asInt32.getValue

		val states = playerStats.keySet
			.filter(key => playerStats.getOrElse(key, BsonNull()).asDocument.getInt32("teamId").getValue == side)
			.map(key => getPlayerState(Document(playerStats.getOrElse(key, BsonNull()).asDocument))).toList
		TeamState(states, barons, dragons, turrets)
	}

	private def getPlayerState(playerStat : Document) : PlayerState = {
		val playerId = RiotId[Player](playerStat.getOrElse("playerId", BsonNull()).asString.getValue)
		val player = getPlayer(playerId)
		val championState = getChampionState(playerStat)
	  val location = getLocationData(playerStat)
		PlayerState(player, championState, location)
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

	private def getPlayer(riotId : RiotId[Player]) : Player = {
		val ob: Observable[Document] = database.getCollection("players").find(equal("id", riotId.id.toInt)).first()
		val data: Document = first[Document](ob)
		val ign = data.getOrElse("name", BsonNull()).asString.getValue
		val role = Role.interpret(data.getOrElse("position", BsonNull()).asString.getValue)
		val teamId = data.getOrElse("teamSlug", BsonNull()).asString.getValue
		Player(riotId, ign, role, teamId)
	}

	private def getTeam(id : Int) = ???
	private def first[T](ob : Observable[T]): T = Await.result(ob.head(), Duration(5,TimeUnit.SECONDS))
	private def results[T](ob : Observable[T]) : Seq[T] = Await.result(ob.toFuture(), Duration(5,TimeUnit.SECONDS))
}

object MongoDBHandler{
  def apply() = new MongoDBHandler()
  def main(args : Array[String]): Unit = {
		val dbh = MongoDBHandler()
	  val gameData = dbh.getCompleteGame(1001790061)
	  gameData.foreach(gs => println(gs))
  }
}
