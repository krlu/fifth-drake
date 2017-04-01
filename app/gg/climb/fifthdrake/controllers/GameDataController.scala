package gg.climb.fifthdrake.controllers

import java.util.concurrent.TimeUnit

import gg.climb.fifthdrake.controllers.requests.{AuthenticatedAction, AuthorizationFilter, TagAction}
import gg.climb.fifthdrake.dbhandling.DataAccessHandler
import gg.climb.fifthdrake.lolobjects.accounts.{Admin, Owner, User, UserGroup}
import gg.climb.fifthdrake.lolobjects.esports.Player
import gg.climb.fifthdrake.lolobjects.game.state._
import gg.climb.fifthdrake.lolobjects.game.{GameData, InGameTeam, MetaData}
import gg.climb.fifthdrake.lolobjects.tagging.{Category, Tag}
import gg.climb.fifthdrake.lolobjects.{InternalId, RiotId}
import gg.climb.fifthdrake.reasoning._
import gg.climb.fifthdrake.{Game, Time, TimeMonoid, Timeline}
import gg.climb.ramenx.Behavior
import play.api.Logger
import play.api.libs.json.{JsArray, JsValue, Json, Writes, _}
import play.api.mvc.{Action, _}

import scala.concurrent.duration.Duration

class GameDataController(dbh: DataAccessHandler,
                         AuthenticatedAction: AuthenticatedAction,
                         AuthorizationFilter: AuthorizationFilter) extends Controller {

  def loadDashboard(gameKey: String): Action[AnyContent] = (AuthenticatedAction andThen AuthorizationFilter) { request =>
    val allGames = dbh.getAllGameIdentifiers.map(identifier => identifier.gameKey.id)
    if(allGames.contains(gameKey))
      Ok(views.html.gameDashboard(request.host, gameKey))
    else
      NotFound
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

  private implicit val userWrites = new Writes[User] {
    override def writes(user: User): JsValue = Json.obj(
      "id" -> user.uuid.toString,
      "email" -> user.email,
      "firstName" -> user.firstName,
      "lastName" -> user.lastName
    )
  }

  def loadTimelineData(gameKey: String): Action[AnyContent] = (AuthenticatedAction andThen AuthorizationFilter) {
    val timeline: Seq[GameEvent] = dbh.getTimelineForGame(new RiotId[Timeline](gameKey))
    implicit val buildingKillWrite = new Writes[BuildingKill] {
      override def writes(event: BuildingKill): JsValue = {
        Json.obj(
          "eventType" -> "BuildingKill",
          "buildingType" -> event.buildingType.name,
          "location" -> Json.obj(
            "x" -> event.loc.x,
            "y" -> event.loc.y
          ),
          "lane" -> event.lane.name,
          "side" -> event.side.name,
          "time" -> event.time.toSeconds
        )
      }
    }

    implicit val baronKillWrite = new Writes[BaronKill] {
      override def writes(event: BaronKill): JsValue = {
        Json.obj(
          "eventType" -> "BaronKill",
          "location" -> Json.obj(
            "x" -> event.loc.x,
            "y" -> event.loc.y
          ),
          "time" -> event.time.toSeconds
        )
      }
    }

    implicit val dragonKillWrite = new Writes[DragonKill] {
      override def writes(event: DragonKill): JsValue = {
        Json.obj(
          "eventType" -> "DragonKill",
          "location" -> Json.obj(
            "x" -> event.loc.x,
            "y" -> event.loc.y
          ),
          "dragonType" -> event.dragonType.name,
          "time" -> event.time.toSeconds
        )
      }
    }

    implicit val gameEventWrite = new Writes[GameEvent] {
      override def writes(teamState: GameEvent): JsValue = teamState match {
        case building : BuildingKill => Json.toJson(building)
        case dragon : DragonKill => Json.toJson(dragon)
        case baron : BaronKill => Json.toJson(baron)
        case _ => Json.obj()
      }
    }

    val listOfEventsJson = timeline.map(event => Json.toJson(event))
    Ok(JsArray(listOfEventsJson))
  }

  // scalastyle:off method.length
  def loadGameData(gameKey: String): Action[AnyContent] =
    (AuthenticatedAction andThen AuthorizationFilter) { request =>
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
            "assists" -> playerState.assists,
            "currentGold" -> playerState.currentGold,
            "totalGold" -> playerState.totalGold
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
        Ok(Json.obj(
            "game" -> Json.toJson(game),
            "currentUser" -> Json.toJson(request.user),
            "permissions" -> Json.toJson(dbh.getGroupPermissionsForUser(request.user.uuid).map{
              case (groupId, permission) =>
                Json.obj(
                  "groupId" -> groupId.toString,
                  "level" -> permission.name)
            })))
      case None =>
        NotFound
    }

  }
  // scalastyle:on method.length

  def getTags(gameKey: String): Action[AnyContent] =
    (AuthenticatedAction andThen AuthorizationFilter andThen TagAction.refiner(gameKey, dbh)) { request =>
      Ok(Json.toJson(request.gameTags))
  }


  private implicit val tagWrites = new Writes[Tag] {
    def writes(tag: Tag): JsObject =
      if(tag.hasInternalId) {
        Json.obj(
          "id" -> tag.id.get.id,
          "title" -> tag.title,
          "description" -> tag.description,
          "category" -> tag.category.name,
          "timestamp" -> tag.timestamp.toSeconds,
          "players" -> Json.toJson(tag.players.map(_.id.id)),
          "author" -> Json.toJson(dbh.getUserByUuid(tag.author)),
          "authorizedGroups" -> tag.authorizedGroups.map(_.uuid.toString)
        )
      }
      else
        Json.obj("error:" -> "Error, tag does not have Id!")
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
  def saveTag: Action[AnyContent] =
    (AuthenticatedAction andThen AuthorizationFilter) { request =>
    val body: AnyContent = request.body
    body.asJson.map{ jsonValue =>
      val data = jsonValue.as[JsObject].value
      val gameKey = data("gameKey").as[String]
      val title = data("title").as[String]
      val description = data("description").as[String]
      val category = data("category").as[String]
      val timeStamp = data("timestamp").as[Int]
      val shareWithGroup = data("shareWithGroup").as[Boolean]
      val players = data("relevantPlayerIds").as[JsArray].value.map{ jsVal =>
        val id = jsVal.as[String]
        dbh.getPlayer(new InternalId[Player](id))
      }.toSet
      val userGroup = dbh.getUserGroupByUser(request.user)
      shareWithGroup match {
        case true =>
          userGroup match {
            case Some(group) =>
              dbh.insertTag(new Tag(new RiotId[Game](gameKey), title, description, new Category(category),
                Duration(timeStamp, TimeUnit.SECONDS), players, request.user.uuid, List(group)))
            case None => BadRequest("Could not share tag with group!")
          }
        case false =>
          dbh.insertTag(new Tag(new RiotId[Game](gameKey), title, description, new Category(category),
            Duration(timeStamp, TimeUnit.SECONDS), players, request.user.uuid, List.empty[UserGroup]))
      }
      Redirect(routes.GameDataController.getTags(gameKey))
    }.getOrElse{
      BadRequest("Failed to insert tag")
    }
  }

  /**
    * Request body MultiFormData should resemble:
    * JsonArr(
    *   "id" -> 0,
    *   "id" -> 1
    *    ....
    * )
    * Share tags with group, provided user belongs to a group
    * If the tag is already shared, simply un-shares the tag
    *
    * @return
    */
  def toggleShareTag: Action[AnyContent] = {
    (AuthenticatedAction andThen AuthorizationFilter) { request =>
      val body: AnyContent = request.body
      body.asJson match {
        case Some(jsonValue) =>
          val data = jsonValue.as[JsObject].value
          val id = data("tagId").as[String]
          val tagId = new InternalId[Tag](id)
          Logger.info(s"Searching for tag with id $tagId")
          dbh.getTagById(tagId) match {
            case None => BadRequest("Tag not found!")
            case Some(tag) =>
              if(tag.author != request.user.uuid)
                BadRequest("User is not the author of this tag!")
              dbh.getUserGroupByUserUuid(request.user.uuid) match {
                case Some(group) =>
                  val isAlreadyShared = tag.authorizedGroups.map(_.uuid).contains(group.uuid)
                  val groupIds =
                    isAlreadyShared match {
                      case true => tag.authorizedGroups.map(_.uuid).filter(_ != group.uuid)
                      case false => tag.authorizedGroups.map(_.uuid) ++ List(group.uuid)
                    }
                  dbh.updateTagsAuthorizedGroups(groupIds, tagId)
                  Ok(Json.obj("tagId" -> id, "groupId" -> group.uuid, "nowShared" -> !isAlreadyShared))
                case None => BadRequest("User does not have group to share with!")
              }
          }
        case None => BadRequest("Missing body data in request!")
      }
    }
  }

  /**
    * Only the author, group owner, or group admin can delete a tag
    *
    * @param tagId - string representation of tag id
    * @return
    */
  def deleteTag(tagId: String): Action[AnyContent] =
    (AuthenticatedAction andThen AuthorizationFilter) { request =>
    val tagInternalId = new InternalId[Tag](tagId)
    def deleteTagHelper(): Result = {
      dbh.deleteTag(tagInternalId)
      Ok(tagId)
    }
    dbh.getTagById(tagInternalId) match {
      case Some(tag) =>
        request.user.uuid.equals(tag.author) match {
          case true => deleteTagHelper()
          case false =>
            dbh.getUserGroupByUser(request.user) match {
              case Some(group: UserGroup) =>
                tag.authorizedGroups.map(_.uuid).contains(group.uuid) match {
                  case true =>
                    dbh.getUserPermissionForGroup(request.user.uuid, group.uuid) match {
                      case Some(Owner) => deleteTagHelper()
                      case Some(Admin) => deleteTagHelper()
                      case _ => BadRequest("Only group owners, admins, or the author can delete this tags!")
                    }
                  case false => BadRequest("Tag not part of this group!")
                }
              case None => BadRequest(s"No group found for user ${request.user.uuid}")
            }
        }
      case None => BadRequest(s"No tag found with id $tagId")
    }
  }
}

