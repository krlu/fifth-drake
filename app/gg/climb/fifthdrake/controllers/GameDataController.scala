package gg.climb.fifthdrake.controllers

import gg.climb.fifthdrake.Game
import gg.climb.fifthdrake.dbhandling.DataAccessHandler
import gg.climb.fifthdrake.lolobjects.RiotId
import gg.climb.fifthdrake.lolobjects.game.JsonWriters
import gg.climb.fifthdrake.lolobjects.tagging.Tag
import play.api.libs.json._
import play.api.mvc._

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

  def loadGameData(gameKey: String): Action[AnyContent] = Action {
    val game = dbh.getGame(new RiotId[Game](gameKey))

    import JsonWriters._
    implicit val bWrites = behaviorWrites(game._1.gameDuration)

    Ok(Json.toJson(game))
  }

  def getTags(gameKey: String): Action[AnyContent] = Action {
    val tags = dbh.getTags(new RiotId[Game](gameKey))
    implicit val tagWrites = new Writes[Tag] {
      def writes(tag: Tag): JsObject = Json.obj(
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

