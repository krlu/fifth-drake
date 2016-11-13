package gg.climb.fifthdrake.controllers

import java.util.concurrent.TimeUnit

import gg.climb.fifthdrake.dbhandling.DataAccessHandler
import gg.climb.fifthdrake.lolobjects.RiotId
import gg.climb.fifthdrake.lolobjects.game.InGameTeam
import gg.climb.fifthdrake.lolobjects.game.state.{Blue, PlayerState, Red}
import gg.climb.fifthdrake.lolobjects.tagging.Tag
import gg.climb.fifthdrake.{Game, Time, TimeMonoid}
import play.api.libs.json.{JsObject, Json, Writes}
import play.api.mvc._

import scala.concurrent.duration.Duration

class GameDataController(dbh : DataAccessHandler) extends Controller {

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

  def loadGameData(gameKey: String): Action[AnyContent] = Action {
    Ok(getGameData(gameKey))
  }
  def getGameData(gameKey: String): JsObject = {
    def getPlayerStates(igt: InGameTeam, gameLength: Time,
      samplingRate: Int = 1000): Seq[JsObject] = {
      val rate = Duration(samplingRate, TimeUnit.MILLISECONDS)
      val start = Duration(0, TimeUnit.MILLISECONDS)
      val playersList = igt.playerStates.map { case (p, behavior) =>
        p -> behavior.sampledBy(start, rate, gameLength)
      }.map { case (p, eventStream) =>
          val champName = eventStream.getAll.head._2.championState.name
          val side = eventStream.getAll.head._2.sideColor.name
          (side, p.role.name, p.ign, champName, eventStream.getAll.map { case (t, ps) =>
          getJsonForPlayerState(p.ign, ps, t)
        })
      }.toSeq.map{
        case (side, roleName, ign, champName, playerData) =>
          Json.obj(
          "side" -> side,
          "role" -> roleName,
          "ign"-> ign,
          "championName" -> champName,
          "playerStates" -> playerData
        )
      }
      playersList
    }
    def getJsonForPlayerState(ign: String,
      playerState: PlayerState,
      timeStamp: Duration): JsObject = Json.obj(
      "position" -> Json.obj(
        "x" -> playerState.location.x,
        "y" -> playerState.location.y
      ),
      "championState" -> Json.obj(
        "hp" -> playerState.championState.hp,
        "mp" -> playerState.championState.mp,
        "xp" -> playerState.championState.xp
      )
    )

    val (metaData, gameData) = dbh.createGame(new RiotId[Game](gameKey))
    val blueData = getPlayerStates(gameData.teams(Blue), metaData.gameDuration)
    val redData = getPlayerStates(gameData.teams(Red), metaData.gameDuration)
    Json.obj("blueTeam" -> blueData, "redTeam" -> redData)
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

