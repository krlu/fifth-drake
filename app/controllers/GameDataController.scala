package controllers

import java.util.concurrent.TimeUnit

import gg.climb.commons.dbhandling.{DataAccessHandler, MongoDbHandler, PostgresDbHandler}
import gg.climb.lolobjects.RiotId
import gg.climb.lolobjects.game.state.{Blue, PlayerState, Red}
import gg.climb.lolobjects.game.{GameData, InGameTeam}
import gg.climb.reasoning.EventMonoid
import org.mongodb.scala.MongoClient
import play.api.libs.json._
import play.api.mvc._

import scala.concurrent.duration.Duration

class GameDataController extends Controller {

  //TODO: hard coded, should parameterize
  val mongoClient: MongoClient = MongoClient("mongodb://localhost")
  val mdbh = new MongoDbHandler(mongoClient)
  val pdbh = new PostgresDbHandler("localhost", 5432, "league_analytics", "kenneth", "asdfasdf")

  val dah = new DataAccessHandler(pdbh, mdbh)

  def getGameData(gameKey: String): JsObject = {
    val (gameData, metaData) = dah.createGame(new RiotId[GameData](gameKey))
    val blueData = Json.obj("playerStats" -> getPlayerStates(gameData.teams(Blue), metaData.gameDuration))
    val redData  = Json.obj("playerStats" -> getPlayerStates(gameData.teams(Red), metaData.gameDuration))
    Json.obj("blueTeam" -> blueData, "redTeam" -> redData)
  }

  private def getPlayerStates(igt: InGameTeam, gameLength: Duration,
                              samplingRate: Int = 1000): JsObject = {
    val rate = Duration(samplingRate, TimeUnit.MILLISECONDS)
    val start = Duration(0, TimeUnit.MILLISECONDS)
    igt.playerStates.map{case (p, behavior) =>
      p -> behavior.sampledBy(start, rate, gameLength)(EventMonoid)
    }.map{ case(p, eventStream) =>
      p.role.name -> eventStream.getAll.map{ case(t, ps) =>
        getJsonForPlayerState(p.ign, ps, t)
      }
    }.foldLeft(Json.obj()){
      case (json: JsObject, (roleName, playerData)) => json ++ Json.obj(roleName -> playerData)
    }
  }

  private def getJsonForPlayerState(ign : String, playerState: PlayerState,
                                    timeStamp: Duration): JsObject = Json.obj(
    "t" -> timeStamp.toMillis,
    "ign" -> ign,
    "side" -> playerState.sideColor.name,
    "location" -> Json.obj(
      "x" -> playerState.location.x,
      "y" -> playerState.location.y
    ),
    "championState" -> Json.obj(
      "championName" -> playerState.championState.name,
      "hp" -> playerState.championState.hp,
      "mp" -> playerState.championState.mp,
      "xp" -> playerState.championState.xp
    )
  )

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

  def loadHomePage: Action[AnyContent] = Action {Ok(views.html.index())}
}
