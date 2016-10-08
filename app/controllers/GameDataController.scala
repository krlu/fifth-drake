package controllers

import gg.climb.commons.dbhandling.MongoDBHandler
import gg.climb.lolobjects.RiotId
import gg.climb.lolobjects.esports.Player
import gg.climb.lolobjects.game.state.{ChampionState, GameState, PlayerState}
import gg.climb.lolobjects.game.{GameIdentifier, LocationData}
import play.api.libs.json.{JsArray, JsObject, Json}
import play.api.mvc._

class GameDataController extends Controller {
  val dbHandler = MongoDBHandler()

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

  def loadHomePage = Action {
                              Ok(views.html.index())
                            }
}

