package controllers

import com.mongodb.Mongo
import gg.climb.commons.dbhandling.MongoDBHandler
import gg.climb.lolobjects.game.state.GameState
import play.api.libs.json.{JsArray, Json}
import play.api.mvc._

import scala.collection.immutable.Seq
import scala.concurrent.duration.Duration

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
			Ok("Jim")
	}

	def showRequest = Action { request =>
		Ok("Got request [" + request + "]")
	}

	def getGameData(gameId: Int) = Action {
		val dBHandler = MongoDBHandler()
		val data: List[GameState] = dBHandler.getCompleteGame(gameId)
		val timeStamps: List[String] = data.map(state => state.timestamp.toString)
		val arrOfTimes = Json.toJson(timeStamps)
		Ok(Json.obj("id" -> gameId, "data"-> arrOfTimes))
	}

	/**
		* Remainder and XP for Next Level default to 0 if current level is 18
		* @param cumulativeXP
		* @return (currentLevel, currentXP remainder, XP for Next Level)
		*/
	def calculateLevel(cumulativeXP : Int): (Int, Int, Int) = {
		val filteredLevels = levels.filter(tuple => tuple._2 < cumulativeXP)
		val levelTuple = filteredLevels(filteredLevels.size - 1)
		val remainder = cumulativeXP - levelTuple._2
		(levelTuple._1, remainder, xpToObtainLvl(levelTuple._1 + 1))
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
		println(mc.calculateLevel(6000))
	}
}

