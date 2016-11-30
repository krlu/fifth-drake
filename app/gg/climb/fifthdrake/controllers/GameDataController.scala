package gg.climb.fifthdrake.controllers

import java.util.concurrent.TimeUnit

import gg.climb.fifthdrake.dbhandling.DataAccessHandler
import gg.climb.fifthdrake.lolobjects.RiotId
import gg.climb.fifthdrake.lolobjects.esports.Player
import gg.climb.fifthdrake.lolobjects.game.state.{Blue, PlayerState, Red, TeamState}
import gg.climb.fifthdrake.lolobjects.game.{GameData, InGameTeam}
import gg.climb.fifthdrake.lolobjects.tagging.{Category, Tag}
import gg.climb.fifthdrake.{Game, Time, TimeMonoid}
import gg.climb.ramenx.Behavior
import play.api.libs.Files.TemporaryFile
import play.api.libs.json._
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

  def loadChampion(name: String): Action[AnyContent] = Action {
    val result = for{
      champ <- dbh.getChampion(name)
    }
    yield {
      Ok(Json.obj("championName" -> champ.name, "championKey" -> champ.key, "championImage" -> champ.image.full))
    }
    result.getOrElse(InternalServerError(s"Could not find champion $name"))
  }

  def loadGameLength(gameKey: String): Action[AnyContent] = Action {
    val (metaData, _) = dbh.getGame(new RiotId[Game](gameKey))
    Ok(Json.obj("gameLength" -> metaData.gameDuration.toSeconds))
  }

  def loadGameData(gameKey: String): Action[AnyContent] = Action {
    val (metaData, gameData) = dbh.getGame(new RiotId[Game](gameKey))

    implicit def behaviorWrites[A](implicit writer : Writes[A]) : Writes[Behavior[Time, A]] =
      new Writes[Behavior[Time, A]] {
        override def writes(behavior: Behavior[Time, A]): JsValue = JsArray(
          behavior
            .sampledBy(Duration.Zero, Duration(1, TimeUnit.SECONDS), metaData.gameDuration)
            .map(writer.writes)
            .getAll
            .map(_._2)
        )
      }

    implicit val teamStateWrite = new Writes[TeamState] {
      override def writes(teamState: TeamState): JsValue = Json.obj(
        "barons" -> teamState.barons,
        "dragons" -> teamState.dragons,
        "turrets" -> teamState.turrets
      )
    }

    implicit val playerStateWrite = new Writes[PlayerState] {
      override def writes(playerState: PlayerState): JsValue = Json.obj(
        "position" -> Json.obj(
          "x" -> playerState.location.x,
          "y" -> playerState.location.y
        ),
        "championState" -> Json.obj(
          "hp" -> playerState.championState.hp,
          "mp" -> playerState.championState.mp,
          "xp" -> playerState.championState.xp
        ))
    }

    def playerStateToJson (p : (Player, Behavior[Time, PlayerState])) : JsValue = p match {
      case (player, states) => Json.obj(
        "side" -> states(Duration.Zero).sideColor.name,
        "role" -> player.role.name,
        "ign" -> player.ign,
        "championName" -> states(Duration.Zero).championState.name,
        "playerStates" -> Json.toJson(states)
      )
    }

    implicit val inGameTeamWrites = new Writes[InGameTeam] {
      override def writes(o: InGameTeam): JsValue = Json.obj(
        "teamStates" -> Json.toJson(o.teamStates),
        "players" -> Json.toJson(o.playerStates.toList.map(playerStateToJson))
      )
    }

    implicit val gameDataWrites = new Writes[GameData] {
      override def writes(o: GameData): JsValue = Json.obj(
        "blueTeam" -> Json.toJson(o.teams(Blue)),
        "redTeam" -> Json.toJson(o.teams(Red))
      )
    }

    Ok(Json.toJson(gameData))
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

  /**
    * Request body should resemble this:
    * Json(
    *  "gameKey" -> "10"
    *  "title" -> "gank occurred top lane"
    *  "description" -> "Top laner ganked by roaming support and jungler"
    *  "category" -> "gank"
    *  "timestamp" -> 1234 (measured in seconds)
    *  "igns" -> JsArray("Hauntzer", "Meteos", "Impact")
    * )
    * @return
    */
  def saveTag(): Action[AnyContent] = Action { request =>
    val body: AnyContent = request.body
    body.asMultipartFormData.map{ (formData: MultipartFormData[TemporaryFile]) =>
      val data: Map[String, Seq[String]] = formData.dataParts
      val gameKey = data("gameKey").head
      val title = data("title").head
      val description = data("description").head
      val category = data("category").head
      val timeStamp = data("timestamp").head.toInt
      val playerIgns = data("player")
      val players = playerIgns.map(ign => dbh.getPlayerByIgn(ign.toString)).toSet
      dbh.insertTag(new Tag(new RiotId[Game](gameKey), title, description,
        new Category(category), Duration(timeStamp, TimeUnit.SECONDS), players))
      Ok("Tag saved!")
    }.getOrElse{
      BadRequest("Failed to insert tag")
    }
  }
}

