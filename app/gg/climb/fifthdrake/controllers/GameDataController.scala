package gg.climb.fifthdrake.controllers

import java.io.File
import java.nio.file.{Files, Paths}
import java.util.concurrent.TimeUnit

import gg.climb.fifthdrake.browser.UserId
import gg.climb.fifthdrake.controllers.requests.{AuthenticatedAction, AuthorizationFilter}
import gg.climb.fifthdrake.dbhandling.DataAccessHandler
import gg.climb.fifthdrake.lolobjects.esports.Player
import gg.climb.fifthdrake.lolobjects.game.state.{Blue, PlayerState, Red, TeamState}
import gg.climb.fifthdrake.lolobjects.game.{GameData, InGameTeam, MetaData}
import gg.climb.fifthdrake.lolobjects.tagging.{Category, Tag}
import gg.climb.fifthdrake.lolobjects.{InternalId, RiotId}
import gg.climb.fifthdrake.{Game, Time, TimeMonoid}
import gg.climb.ramenx.Behavior
import play.api.libs.Files.TemporaryFile
import play.api.libs.iteratee.Enumerator
import play.api.libs.json.{JsArray, JsValue, Json, Writes, _}
import play.api.mvc.{Action, _}
import play.api.mvc.

import scala.concurrent.duration.Duration

class GameDataController(dbh: DataAccessHandler,
                         AuthenticatedAction: AuthenticatedAction,
                         AuthorizationFilter: AuthorizationFilter) extends Controller {

  def loadDashboard(gameKey: String): Action[AnyContent] = (AuthenticatedAction andThen AuthorizationFilter) { request =>
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

  // scalastyle:off method.length
  def loadGameData(gameKey: String): Action[AnyContent] = (AuthenticatedAction andThen AuthorizationFilter) {
    dbh.getGame(new RiotId[Game](gameKey)) match {
      case Some(game@(metadata, _)) =>
        implicit def behaviorWrites[A]
        (implicit writer: Writes[A])
        : Writes[Behavior[Time, A]] =
          new Writes[Behavior[Time, A]] {
            override def writes(behavior: Behavior[Time, A]): JsValue = JsArray(
              behavior
                .sampledBy(Duration.Zero, Duration(1, TimeUnit.SECONDS), metadata.gameDuration)
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
              "hpMax" -> playerState.championState.hpMax,
              "power" -> playerState.championState.power,
              "powerMax" -> playerState.championState.powerMax,
              "xp" -> playerState.championState.xp
            ),
            "kills" -> playerState.kills,
            "deaths" -> playerState.deaths,
            "assists" -> playerState.assists
          )
        }

        def playerStateToJson(p: (Player, Behavior[Time, PlayerState])): JsValue = p match {
          case (player, states) => Json.obj(
            "id" -> player.id.id,
            "role" -> player.role.name,
            "ign" -> player.ign,
            "championName" -> states(Duration.Zero).championState.name,
            "championImage" -> {
              val champImg = for {
                champion <- dbh.getChampion(states(Duration.Zero).championState.name)
              } yield controllers.routes.Assets.versioned(s"champion/${champion.image.full}").url
              champImg.getOrElse[String](controllers.routes.Assets.versioned("champion/unknown.png").url)
            },
            "playerStates" -> Json.toJson(states)
          )
        }

        implicit val inGameTeamWrites = new Writes[InGameTeam] {
          override def writes(o: InGameTeam): JsValue = Json.obj(
            "teamStates" -> Json.toJson(o.teamStates),
            "players" -> Json.toJson(o.playerStates.toList.map(playerStateToJson))
          )
        }

        implicit val metaDataWrites = new Writes[MetaData] {
          override def writes(o: MetaData): JsValue = Json.obj(
            "gameLength" -> o.gameDuration.toSeconds,
            "blueTeamName" -> o.blueTeamName,
            "redTeamName" -> o.redTeamName
          )

        }

        implicit val gameDataWrites = new Writes[GameData] {
          override def writes(o: GameData): JsValue = Json.obj(
            "blueTeam" -> Json.toJson(o.teams(Blue)),
            "redTeam" -> Json.toJson(o.teams(Red))
          )
        }

        implicit val gameWrites = new Writes[Game] {
          override def writes(o: (MetaData, GameData)): JsValue = o match {
            case (metaData, data) => Json.obj(
              "metadata" -> Json.toJson(metaData),
              "data" -> Json.toJson(data)
            )
          }
        }

        Ok(Json.toJson(game))
      case None =>
        NotFound
    }

  }
  // scalastyle:on method.length

  def getTags(gameKey: String): Action[AnyContent] = (AuthenticatedAction andThen AuthorizationFilter) {
    Ok(loadTagData(gameKey))
  }

  private def loadTagData(gameKey: String): JsValue = {
    val tags = dbh.getTags(new RiotId[Game](gameKey))
    implicit val tagWrites = new Writes[Tag] {
      def writes(tag: Tag): JsObject =
        if(tag.hasInternalId) {
          Json.obj(
            "id" -> tag.id.get.id,
            "title" -> tag.title,
            "description" -> tag.description,
            "category" -> tag.category.name,
            "timestamp" -> tag.timestamp.toSeconds,
            "players" -> Json.toJson(tag.players.map(_.id.id))
          )
        }
        else
          Json.obj("error:" -> "Error, tag does not have Id!")
    }
    Json.toJson(tags)
  }
  /**
    * Request body MultiFormData should resemble:
    * Map(
    *  "gameKey" -> "10"
    *  "title" -> "gank occurred top lane"
    *  "description" -> "Top laner ganked by roaming support and jungler"
    *  "category" -> "gank"
    *  "timestamp" -> 1234  //measured in seconds
    *  "relevantPlayerIgns" -> JsArray("Hauntzer", "Meteos", "Impact")
    *  "allplayerIgns" -> JSObject // contains all players
    *                              // Uses key value pair: (playerIgn -> playerId)
    * )
    *
    * @return Ok if successful, otherwise BadRequest
    */
  def saveTag(): Action[AnyContent] = Action { request =>
    val body: AnyContent = request.body
    body.asJson.map{ jsonValue =>
      val data = jsonValue.as[JsObject].value
      val gameKey = data("gameKey").as[String]
      val title = data("title").as[String]
      val description = data("description").as[String]
      val category = data("category").as[String]
      val timeStamp = data("timestamp").as[Int]
      val players = data("relevantPlayerIds").as[JsArray].value.map{ jsVal =>
        val id = jsVal.as[String]
        dbh.getPlayer(new InternalId[Player](id))
      }.toSet
      dbh.insertTag(new Tag(new RiotId[Game](gameKey), title, description,
        new Category(category), Duration(timeStamp, TimeUnit.SECONDS), players))
      Ok(loadTagData(gameKey))
    }.getOrElse{
      BadRequest("Failed to insert tag")
    }
  }

  def deleteTag(tagId: String): Action[AnyContent] = Action {
    dbh.deleteTag(new InternalId[Tag](tagId))
    Ok(tagId)
  }

  /**
    * Request MultipartForm contains an audio file encoded in Ogg
    *
    * File in the form should be named "audio_note"
    * Query String should contain "t={timestamp in s}"
    * Saves file to /data/audio/notes
    *
    * @param gameKey used to associate note with game
    * @return If successful, OK with a "success" flash session
    */
  def saveAudioNote(gameKey: String): Action[MultipartFormData[TemporaryFile]] =
    (AuthenticatedAction andThen AuthorizationFilter)(parse.multipartFormData) { request =>
      val time: Option[String] = request.queryString.get("t").map(_.head)

      time match {
        case Some(t) => {
          var filename = s"${gameKey}_${request.session.get(UserId.name)}_$t.ogg"

          var count = 1
          while (Files.exists(Paths.get(s"/data/audio/notes/$filename"))) {
            filename = s"${gameKey}_${request.session.get(UserId.name)}_${t}_$count.ogg"
            count += 1
          }

          request.body.file("audio_note").map { audio =>
            audio.ref.moveTo(new File(s"/data/audio/notes/$filename"))
            Ok().flashing("success" -> "audio note successfully saved")
          }.getOrElse(
            Ok().flashing("error" -> "failed to receive audio file")
          )
        }
        case None => {
          Ok().flashing("error" -> "no timestamp specified")
        }
      }
  }

  /**
    * Find all saved audio notes for a specific game key
    *
    * @param gameKey
    * @return Ok, with a json body where audioNotes is an array of all saved audio filenames
    */
  def findAudioNotes(gameKey: String): Action[AnyContent] =
    (AuthenticatedAction andThen AuthorizationFilter) { request =>
      val audioNotesDir = new File("/data/audio/notes")
      if (audioNotesDir.exists && audioNotesDir.isDirectory) {
        val audioNotes = audioNotesDir.listFiles
          .filter(_.isFile)
          .toList
          .filter(_.getName.split("_")(0) == gameKey)
          .map(_.getName)
        Ok(Json.obj(
          "audioNotes" -> audioNotes
        ))
      } else {
        Ok(Json.obj(
          "audioNotes" -> Json.arr()
        ))
      }
  }

  /** Load an audio note from a specific game key
    *
    * Query string should contain "f={filename}"
    *
    * @param gameKey
    * @return
    */
  def getAudioNote(gameKey: String): Action[AnyContent] =
    (AuthenticatedAction andThen AuthorizationFilter) { request =>
      val filename: Option[String] = request.queryString.get("f").map(_.head)
      filename match {
        case Some(f) => {
          val file = new File(s"/data/audio/notes/$f")
          if (file.exists && file.isFile) {
            val content = Enumerator.fromFile(file)
            Ok(content).withHeaders(CONTENT_LENGTH -> file.length.toString)
          } else {
            Ok().flashing("error" -> "file does not exist")
          }
        }
        case None => Ok().flashing("error" -> "no filename specified")
      }
  }
}

