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
      10*(level - 1)*(18 + 5*level)
    }
    else {
      throw new IllegalArgumentException(s"Level `$level' is not a possible level in League of Legends")
    }

  def getCurrentLevel(xp: Int): Int =
    if (xp > 0 && xp <= 18360) {
      ((Math.sqrt(2 * xp + 529) - 13)/10).toInt
    }
    else {
      throw new IllegalArgumentException(s"Cannot have `$xp' xp")
    }

  def loadHomePage = Action {
    Ok(views.html.main())
  }

  def allGames() = Action {

    def buildGIDJson(gameIdentifier : GameIdentifier) : JsObject =
      Json.obj("gameKey"-> gameIdentifier.gameKey.id,
        "gameDate" -> gameIdentifier.gameDate.toDate(),
        "team1" -> gameIdentifier.teamName1,
        "team2" -> gameIdentifier.teamName2,
        "vodURL"-> gameIdentifier.metaData.vodURL.toString())

    val gids: List[JsObject] = dbHandler.getAllGIDs.sortWith((x,y) => x.gameDate.compareTo(y.gameDate) < 1).map(buildGIDJson)
    Ok(views.html.Application.games(gids))
  }

  def getGameData(gameId: String, vodID : String) = Action {
    val data: List[GameState] = dbHandler.getCompleteGame(new RiotId(gameId))
    var arrOfStates: JsArray = Json.arr()
    for(gameState <- data){
      arrOfStates = arrOfStates.append(buildJson(gameState))
    }
    val vodURL = vodID.replace("\"", "")
    val json: JsObject = Json.obj("id" -> gameId, "data"-> arrOfStates, "vodURL" -> vodURL)
    Ok(views.html.Application.gamepage(json))
  }

  def buildJson(state : GameState): JsObject ={
    var playerArray = Json.arr()
    val allPlayers = state.red.players ++ state.blue.players
    for(player <- allPlayers)
      playerArray = playerArray.append(buildPlayerStateJson(player))
    Json.obj("timeStamp" -> state.timestamp.toMillis, "players" -> playerArray)
  }

  private def buildPlayerStateJson(playerState: PlayerState): JsObject ={
    Json.obj("side" -> playerState.sideColor, "player" -> buildPlayerJson(playerState.player),
      "location" -> buildLocationJson(playerState.location),
      "champion" -> buildChampionStateJson(playerState.championState))
  }
  private def buildPlayerJson(player: Player): JsObject = Json.obj("riotId" -> player.riotId.id,
    "ign" -> player.ign, "role" -> player.role.name, "team" -> player.team)

  private def buildLocationJson(location: LocationData): JsObject = Json.obj("x" -> location.x,
    "y" -> location.y, "confidence" -> location.confidence)

  private def buildChampionStateJson(championState: ChampionState):JsObject = {
    val lvlData: (Int, Int, Int) = calculateLevel(championState.xp.toInt)
    Json.obj("hp" -> championState.hp, "mp" -> championState.mp, "cumulativeXP" -> championState.xp,
      "lvl" -> lvlData._1, "xp" -> lvlData._2, "xpNeededToLvl"-> lvlData._3, "name" -> championState.name)
  }


  /**
    * Remainder and XP for Next Level default to 0 if current level is 18
 *
    * @param cumulativeXP Total xp for the champion
    * @return (currentLevel, currentXP remainder, XP for Next Level)
    */
  def calculateLevel(cumulativeXP: Int): (Int, Int, Int) = {
    val currentLevel: Int = getCurrentLevel(cumulativeXP)
    val remainder = cumulativeXP - xpRequiredForLevel(currentLevel)
    val xpNeededForNextLvl = xpToObtainLvl(currentLevel + 1) - remainder
    (currentLevel, remainder, xpNeededForNextLvl)
  }

  /**
    * @param lvl The current level of the champion
    * @return non-cumulative XP needed to obtain level
    */
  def xpToObtainLvl(lvl : Int): Int = if (lvl < 2 || lvl > 18) 0 else 100 * (lvl - 2) + 280
}
