package gg.climb.commons.dbhandling

import java.util
import java.util.{ArrayList, OptionalDouble}

import com.mongodb.client.MongoCursor
import com.mongodb.{BasicDBList, BasicDBObject, MongoClient}
import gg.climb.lolobjects.esports._
import gg.climb.lolobjects.game.{ImmutableLocationData, PlayerState, PlayerStateBuilder}
import gg.climb.lolobjects.{ImmutableInternalId, ImmutableRiotId, InternalId}
import org.bson.Document

import scala.collection.mutable

class MongoDBHandler(){
  val mongoClient: MongoClient = new MongoClient("localhost" , 27017);
  val names  = mongoClient.listDatabaseNames()
  val database = mongoClient.getDatabase("league_analytics")


	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////// Getter Time Series Data//////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	def getPlayerStatesForGame(gameKey : Int): List[(Integer,List[PlayerState])] = {
		val raw_data = getGameData(gameKey)
		val entireGame = new mutable.MutableList[(Integer,List[PlayerState])]
		while(raw_data.hasNext) {
			val raw_stats = raw_data.next()
			val time = raw_stats.getInteger("t")
			val players = raw_stats.get("playerStats").asInstanceOf[Document]
			val keyIt: util.Iterator[String] = players.keySet().iterator()
			var playerStates = List.empty[PlayerState]
			while(keyIt.hasNext()){
				val builder = new PlayerStateBuilder()
				val player = players.get(keyIt.next()).asInstanceOf[Document]
				val loc = getRealLocationData(player)
				val playerRiotId = ImmutableRiotId.of(player.get("playerId").toString).asInstanceOf[ImmutableRiotId[Player]]
				println(playerRiotId)
				val state = builder.location(loc)
					.hp(player.getInteger("h").toDouble)
					.mp(player.getInteger("p").toDouble)
					.xP(player.getInteger("xp").toDouble).championName(player.getString("championName"))
					.summoner(getPlayerByRiotId(playerRiotId)).timeStamp(time.toLong)
					.build()
				playerStates = state :: playerStates
			}
			entireGame.+=:(time, playerStates)
		}
		return entireGame.toList.sortWith(_._1<_._1)
	}

	private def getRealLocationData(rawData : Document) : ImmutableLocationData = {
		val xCoord = rawData.get("x").toString.toDouble
		val yCoord = rawData.get("y").toString.toDouble
		val location: ImmutableLocationData = ImmutableLocationData.of(xCoord,yCoord, OptionalDouble.of(1.0))
		return location
	}
	/**
		* Returns raw json data of time series data for a given game
		*
		* @param gameKey
		* @return MongoCursor[Document]
		*/
	def getGameData(gameKey : Int): MongoCursor[Document] ={
		val data: MongoCursor[Document] = database.getCollection("game_" + gameKey).find().iterator()
		return data
	}

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////// Getter for Static Data///////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/**
		* @param riotId
		*/
	def getPlayerByRiotId(riotId: ImmutableRiotId[Player]): Player ={
		val builder = ImmutablePlayer.builder()
		val playerData = getPlayerData(riotId)
		if(playerData == null)
			return null
		val currentTeam: Document = getTeamData(playerData.getString("teamSlug"))
		return builder.internalId(ImmutableInternalId.of(-1)).firstName("").lastName("")
			.ign(playerData.getString("name")).riotId(ImmutableRiotId.of(playerData.get("id").toString))
		  .role(Role.interpret(playerData.getString("position")))
			.currentTeamId(ImmutableInternalId.of(currentTeam.getInteger("id")))
			.region(currentTeam.getString("region")).teamIds(new util.ArrayList[InternalId[_]]()).build()

	}

	def getTeam(teamSlug : String) : Team = {
		val teamData = getTeamData(teamSlug)
		val builder = new TeamBuilder()
		val riotId = ImmutableRiotId.of(teamData.getInteger("id").toString)
		val internalId = ImmutableInternalId.of(teamData.getInteger("id"))
		val playerRiotIdsIt = teamData.get("players").asInstanceOf[util.ArrayList[Int]].iterator()
		val players = new util.ArrayList[Player]()
		while(playerRiotIdsIt.hasNext){
			val riotId = ImmutableRiotId.of(playerRiotIdsIt.next().toString).asInstanceOf[ImmutableRiotId[Player]]
			println(riotId)
			val player = getPlayerByRiotId(riotId)
			if(player != null)
				players.add(getPlayerByRiotId(riotId))
		}
		val team = builder.acronym(teamData.getString("acronym")).name(teamData.getString("name")).riotId(riotId)
			.internalId(internalId).players(players).build()
		return team
	}

	/**
		* NOTE: Iterator should only contain 1 element hence we return after iterating once!
		* @param riotId
		* @return Document of player data
		*/
	private def getPlayerData(riotId: ImmutableRiotId[Player]) : Document ={
		val dbObject = new BasicDBObject()
		dbObject.append("id", riotId.getId.toInt)
		val data: MongoCursor[Document] = database.getCollection("players").find(dbObject).iterator()
		while(data.hasNext){
			return data.next()
		}
		return null
	}

	/**
		* NOTE: Iterator should only contain 1 element hence we return after iterating once!
		* @param teamSlug
		* @return Document of team data
		*/
	private def getTeamData(teamSlug : String) : Document = {
		val dbObject = new BasicDBObject()
		dbObject.append("slug", teamSlug.toLowerCase)
		val data: MongoCursor[Document] = database.getCollection("teams").find(dbObject).iterator()
		while(data.hasNext()){
			return data.next()
		}
		return null
	}
	/**
		* Gets identifiers for games where given team is playing
		* @param team - team acronym
		* @return MongoCursor[Document] - iterator over documents with team acronym
		*/
	def getGameIdentifiersByTeam(team : String) : MongoCursor[Document] =  {
		val or = atomicOrQuery(List(("team1", team), ("team2", team)))
		return database.getCollection("lcs_game_identifiers").find(or).iterator()
	}

	/**
		* Gets identifiers for games where given teams are playing each other
		* @param team1 - team1 acronym
		* @param team2 - team2 acronym
		* @return MongoCursor[Document] - iterator over documents with team acronym
		*/
	def getGameIdentifiersByMatchup(team1 : String, team2: String): MongoCursor[Document] = {
		val andQuery1 = atomicAndQuery(List(("team1", team1), ("team2", team2)))
		val andQuery2 = atomicAndQuery(List(("team1", team2), ("team2", team1)))
		val orQuery1 = orQuery(List(andQuery1, andQuery2))
		return database.getCollection("lcs_game_identifiers").find(orQuery1).iterator()
	}

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////// Helper Methods for Querying//////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	def atomicOrQuery(queries: List[(String, Any)]) : BasicDBObject = {
		val dbObjects: List[BasicDBObject] = queries.map( s => new BasicDBObject(s._1, s._2))
		return aggregateQuery(dbObjects, "$or")
	}
	def atomicAndQuery(queries: List[(String, Any)]) : BasicDBObject = {
		val dbObjects: List[BasicDBObject] = queries.map( s => new BasicDBObject(s._1, s._2))
		return aggregateQuery(dbObjects, "$and")
	}
	def orQuery(queries : List[BasicDBObject]) : BasicDBObject  = aggregateQuery(queries, "$or")
	def andQuery(queries : List[BasicDBObject]) : BasicDBObject = aggregateQuery(queries, "$and")

	/**
		* Helper method for composing multiple queries under $and or $or
		* @param queries - list of child queries to compose
		* @param queryType - either $and or $or
		* @return BasicDBObject - a composed query
		*/
	private def aggregateQuery(queries : List[BasicDBObject], queryType : String): BasicDBObject ={
		val toReturn = new ArrayList[BasicDBObject]
		for(query <- queries){
			toReturn.add(query)
		}
		return new BasicDBObject(queryType, toReturn)
	}

	def getIdentifiersAfterDate(time : Long): MongoCursor[Document] = this.database.getCollection("lcs_game_identifiers")
		.find(queryGreaterThan("gameDate", time)).iterator()
	def queryLessThanOrEq(field : String, compareValue : Long) : BasicDBObject = compareQuery(field, compareValue, "$lte")
	def queryGreaterThanOrEq(field : String, compareValue : Long) : BasicDBObject = compareQuery(field, compareValue, "$gte")
	def queryLessThan(field : String, compareValue : Long) : BasicDBObject = compareQuery(field, compareValue, "$lt")
	def queryGreaterThan(field : String, compareValue : Long) : BasicDBObject = compareQuery(field, compareValue, "$gt")

	/**
		* Helper method for comparing field against a value
		* @param field - field we want to compare
		* @param compareValue - value to compare against
		* @param queryType - comparator
		* @return BasicDBObject - output query
		*/
	private def compareQuery(field: String, compareValue: Double, queryType: String): BasicDBObject = {
		new BasicDBObject(field, new BasicDBObject(queryType, compareValue));
	}
}

object MongoDBHandler{
  def apply() = new MongoDBHandler()
  def main(args : Array[String]): Unit = {
    val dbh = MongoDBHandler()
//	  val team = dbh.getTeam("immortals")
//	  val playerIt = team.getPlayers().iterator()
//	  while(playerIt.hasNext){
//		  println(playerIt.next())
//	  }
//	  val player = dbh.getPlayer("huni")
//	  println(player)
		val states = dbh.getPlayerStatesForGame(1001790043)
	  for(state <- states){
		  println(state)
	  }
	  println(states.size)
  }
}
