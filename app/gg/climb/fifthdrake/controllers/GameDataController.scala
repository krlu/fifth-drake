package gg.climb.fifthdrake.controllers

import java.util.concurrent.TimeUnit

import gg.climb.fifthdrake.dbhandling.{DataAccessHandler, MongoDbHandler, PostgresDbHandler}
import gg.climb.fifthdrake.lolobjects.RiotId
import gg.climb.fifthdrake.lolobjects.game.InGameTeam
import gg.climb.fifthdrake.lolobjects.game.state.{Blue, PlayerState, Red}
import gg.climb.fifthdrake.lolobjects.tagging.Tag
import gg.climb.fifthdrake.{Game, Time, TimeMonoid}
import org.mongodb.scala.MongoClient
import play.api.libs.json.{JsObject, Json, Writes}
import play.api.mvc._

import scala.concurrent.duration.Duration

class GameDataController extends Controller {

  val dbh = new DataAccessHandler(
    new PostgresDbHandler("localhost",
      5432,
      "league_analytics",
      "kenneth",
      ""),
    new MongoDbHandler(MongoClient("mongodb://localhost"))
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

  def loadDashboard(gameKey: String): Action[AnyContent] = Action {
    Ok(views.html.gameDashboard())
  }

  def getGameData(gameKey: String): Action[AnyContent] = Action {
    def getPlayerStates(igt: InGameTeam, gameLength: Time,
      samplingRate: Int = 1000): JsObject = {
      val rate = Duration(samplingRate, TimeUnit.MILLISECONDS)
      val start = Duration(0, TimeUnit.MILLISECONDS)
      igt.playerStates.map { case (p, behavior) =>
        p -> behavior.sampledBy(start, rate, gameLength)
      }.map { case (p, eventStream) =>
        p.role.name -> eventStream.getAll.map { case (t, ps) =>
          getJsonForPlayerState(p.ign, ps, t)
        }
      }.foldLeft(Json.obj()) {
        case (json: JsObject, (roleName, playerData)) => json ++ Json
          .obj(roleName -> playerData)
      }
    }

    def getJsonForPlayerState(ign: String,
      playerState: PlayerState,
      timeStamp: Duration): JsObject =
    Json.obj(
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

    val (metaData, gameData) = dbh.createGame(new RiotId[Game](gameKey))
    val blueData = Json.obj("playerStats" -> getPlayerStates(gameData.teams(Blue), metaData.gameDuration))
    val redData = Json.obj("playerStats" -> getPlayerStates(gameData.teams(Red), metaData.gameDuration))
    Ok(Json.obj("blueTeam" -> blueData, "redTeam" -> redData))
  }


  def getTags(gameKey: String): Action[AnyContent] = Action {
    val tags = dbh.getTags(new RiotId[Game](gameKey))
    implicit val tagWrites = new Writes[Tag] {
      def writes(tag: Tag) = Json.obj(
        "title" -> tag.title,
        "description" -> tag.description,
        "category" -> tag.category.name,
        "timestamp" -> tag.timestamp.toSeconds,
        "players" -> Json.toJson(tag.players.map(_.ign))
      )
    }
    Ok(Json.toJson(tags))
  }
}

