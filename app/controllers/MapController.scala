package controllers

import gg.climb.commons.dbhandling.MongoDBHandler
import gg.climb.lolobjects.esports.Player
import gg.climb.lolobjects.game.LocationData
import gg.climb.lolobjects.game.state.{ChampionState, GameState, PlayerState}
import play.api.libs.json.{JsArray, JsObject, Json}
import play.api.mvc._

class MapController extends Controller {
	val levels = List((1, 0),
										(2, 280),
										(3,	660),
										(4,	1140),
										(5,	1720),
										(6,	2400),
										(7,	3180),
										(8,	4060),
										(9,	5040),
										(10, 6120),
										(11, 7300),
										(12, 8580),
										(13, 9960),
										(14, 11440),
										(15, 13020),
										(16, 14700),
										(17, 16480),
										(18, 18360))

	def getName = Action {
			Ok(views.html.index("hello world"))
	}

	def showRequest = Action { request =>
		Ok("Got request [" + request + "]")
	}

	def getGameData(gameId: Int) = Action {
		val dBHandler = MongoDBHandler()
		val data: List[GameState] = dBHandler.getCompleteGame(gameId)
		var arrOfStates: JsArray = Json.arr()
		for(gameState <- data){
			arrOfStates = arrOfStates.append(buildJson(gameState))
		}
		Ok(Json.obj("id" -> gameId, "data"-> arrOfStates))
	}

	def buildJson(state : GameState): JsObject ={
		var playerArray = Json.arr()
		val allPlayers = state.red.players ++ state.blue.players
		for(player <- allPlayers)
			playerArray = playerArray.append(buildPlayerStateJson(player))
		Json.obj("timeStamp" -> state.timestamp.toMillis, "players" -> playerArray)
	}

	def buildPlayerStateJson(playerState: PlayerState): JsObject ={
		Json.obj("side" -> playerState.sideColor, "player" -> buildPlayerJson(playerState.player),
			"location" -> buildLocationJson(playerState.location),
			"champion" -> buildChampionStateJson(playerState.championState))
	}
	def buildPlayerJson(player: Player): JsObject = Json.obj("riotId" -> player.riotId.id,
		"ign" -> player.ign, "role" -> player.role.name, "team" -> player.team)

	def buildLocationJson(location: LocationData): JsObject = Json.obj("x" -> location.x,
		"y" -> location.y, "confidence" -> location.confidence)

	def buildChampionStateJson(championState: ChampionState):JsObject = {
		val lvlData: (Int, Int, Int) = calculateLevel(championState.xp.toInt)
		Json.obj("hp" -> championState.hp, "mp" -> championState.mp, "cumulativeXP" -> championState.xp,
			"lvl" -> lvlData._1, "xp" -> lvlData._2, "xpNeededToLvl"-> lvlData._3, "name" -> championState.name)
	}


	/**
		* Remainder and XP for Next Level default to 0 if current level is 18
		*
		* @param cumulativeXP
		* @return (currentLevel, currentXP remainder, XP for Next Level)
		*/
	def calculateLevel(cumulativeXP: Int): (Int, Int, Int) = {
		val filteredLevels: List[(Int, Int)] = levels.filter(tuple => tuple._2 <= cumulativeXP)
		if(filteredLevels.size == levels.size)
			(18, 0, 0)
		else {
			val levelTuple: (Int, Int) = filteredLevels(filteredLevels.size - 1)
			val remainder = cumulativeXP - levelTuple._2
			val xpNeededForNextLvl = xpToObtainLvl(levelTuple._1 + 1) - remainder
			(levelTuple._1, remainder, xpNeededForNextLvl)
		}
	}

	/**
		* @param lvl
		* @return non-cumulative XP needed to obtain next level
		*/
	def xpToObtainLvl(lvl : Int): Int = {
		if (lvl < 2 || lvl > 18)
			throw new IllegalArgumentException("lvl must be between 2 and 18 inclusive, but was" + lvl)
		100 * (lvl - 2) + 280
	}
}

object MapController {
	def main(args : Array[String]): Unit ={
		val mc = new MapController
		println(mc.calculateLevel(60000))
	}
}

