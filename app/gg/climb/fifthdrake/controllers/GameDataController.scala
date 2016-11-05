package gg.climb.fifthdrake.controllers

import gg.climb.fifthdrake.Game
import gg.climb.fifthdrake.dbhandling.{DataAccessHandler, MongoDbHandler, PostgresDbHandler}
import gg.climb.fifthdrake.lolobjects.RiotId
import gg.climb.fifthdrake.lolobjects.tagging.Tag
import org.mongodb.scala.MongoClient
import play.api.libs.json.{Json, Writes}
import play.api.mvc._

class GameDataController extends Controller {

  val dbh = new DataAccessHandler(
    new PostgresDbHandler("localhost", 5432, "league_analytics", "", ""),
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

  def loadHomePage: Action[AnyContent] = Action {
    Ok(views.html.index())
  }

  def getTag(gameId: Int) : Action[AnyContent] = Action {
    val tags = dbh.getTags(new RiotId[Game](gameId.toString))
    implicit val tagWrites = new Writes[Tag] {
      def writes(tag: Tag) = Json.obj(
        "title" -> tag.title,
        "description" -> tag.description,
        "category" -> tag.category.name,
        "timestamp" -> tag.timestamp.toMillis,
        "players" -> Json.toJson(tag.players.map(_.ign))
      )
    }
    Ok(Json.toJson(tags))
  }
}

