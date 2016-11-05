package gg.climb.controllers

import gg.climb.commons.dbhandling.{DataAccessHandler, MongoDbHandler, PostgresDbHandler}
import gg.climb.lolobjects.RiotId
import gg.climb.lolobjects.tagging.Tag
import gg.climb.ramenx.core.EventStream
import gg.climb.{Game, Time}
import org.mongodb.scala.MongoClient
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
    val tags : EventStream[Time, Tag] = dbh.getTags(new RiotId[Game](gameId.toString))
    Ok("")
  }
}

