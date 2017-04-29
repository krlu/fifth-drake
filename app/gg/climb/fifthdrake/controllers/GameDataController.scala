package gg.climb.fifthdrake.controllers

import java.util.concurrent.TimeUnit

import gg.climb.fifthdrake.controllers.requests._
import gg.climb.fifthdrake.dbhandling.DataAccessHandler
import gg.climb.fifthdrake.lolobjects.accounts.{User, UserGroup}
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

  private def getTimelineForGame(gameKey: String): JsArray = {
    val timeline: Seq[GameEvent] = dbh.getTimelineForGame(new RiotId[Timeline](gameKey))
    implicit val gameEventWrite = new Writes[GameEvent] {
      override def writes(event: GameEvent): JsValue = event match {
        case objective: Objective =>
          val unitKilled = objective match {
            case building: BuildingKill => building.buildingType.name
            case dragon: DragonKill => dragon.dragonType.name
            case baron: BaronKill => "BaronNashor"
            case _ => ""
          }
          Json.obj(
            "unitKilled" -> unitKilled,
            "killerId" -> objective.killerId.id.toInt,
            "timestamp" -> objective.timestamp.toSeconds,
            "position" -> Json.obj(
              "x" -> objective.location.x,
              "y" -> objective.location.y
            )
          )
        case _ => Json.obj()
      }
    }

    val listOfEventsJson = timeline.map(event => Json.toJson(event))
    JsArray(listOfEventsJson)
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
            "participantId" -> states(Duration.Zero).participantId,
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
          }),
          "timeline" -> getTimelineForGame(gameKey)
        ))
      case None =>
        NotFound
    }

  }
  // scalastyle:on method.length

  def getTags(gameKey: String): Action[AnyContent] =
    (AuthenticatedAction andThen AuthorizationFilter andThen TagAction.refiner(gameKey, dbh)) { request =>
      val gameData = dbh.getGame(new RiotId[Game](gameKey))
      val timelineEvents: Seq[GameEvent] = dbh.getTimelineForGame(new RiotId[Timeline](gameKey))
      val autoGenTags = EventFinder.generateObjectivesTags(gameData,timelineEvents, gameKey, request.request.user.uuid)
      Ok(Json.toJson(request.gameTags ++ autoGenTags))
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
    *  "shareWithGroup" -> True // True if and only if sharing directly to group, otherwise false
    * )
    *
    * @return Ok if successful, otherwise BadRequest
    */
  def saveTag: Action[AnyContent] =
    (AuthenticatedAction andThen AuthorizationFilter) { request =>
    val body: AnyContent = request.body
    body.asJson match {
      case Some(jsonValue) =>
        val data = jsonValue.as[JsObject].value
        val gameKey = data("gameKey").as[String]
        val title = data("title").as[String]
        val description = data("description").as[String]
        val category = data("category").as[String]
        val timeStamp = data("timestamp").as[Int]
        val players = data("relevantPlayerIds").as[JsArray].value.map { jsVal =>
          val id = jsVal.as[String]
          dbh.getPlayer(new InternalId[Player](id))
        }.toSet
        data.get("tagId") match {
          case Some(x) =>
            val tagId = new InternalId[Tag](x.as[String])
            dbh.updateTag(new Tag(Some(tagId), new RiotId[Game](gameKey), title, description, new Category(category),
              Duration(timeStamp, TimeUnit.SECONDS), players, request.user.uuid, List.empty[UserGroup]
            ))
          case None =>
            dbh.insertTag(new Tag(new RiotId[Game](gameKey), title, description, new Category(category),
              Duration(timeStamp, TimeUnit.SECONDS), players, request.user.uuid, List.empty[UserGroup]
            ))
        }
        Redirect(routes.GameDataController.getTags(gameKey))
      case nothing => BadRequest("Failed to insert tag")
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
    * Note, sharing a tag means the group owner/admins can delete the tag
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
              tag.author != request.user.uuid match {
                case true =>
                  BadRequest("User is not the author of this tag!")
                case false =>
                  dbh.getUserGroupByUserUuid(request.user.uuid) match {
                    case Some(group) =>
                      val isAlreadyShared = tag.authorizedGroups.map(_.uuid).contains(group.uuid)
                      val groupIds = isAlreadyShared match {
                        case true => tag.authorizedGroups.map(_.uuid).filter(_ != group.uuid)
                        case false => tag.authorizedGroups.map(_.uuid) ++ List(group.uuid)
                      }
                      dbh.updateTagsAuthorizedGroups(groupIds, tagId)
                      Ok(Json.obj("tagId" -> id, "groupId" -> group.uuid, "nowShared" -> !isAlreadyShared))
                    case None => BadRequest("User does not have group to share with!")
                  }
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
                  case true => deleteTagHelper()
                  case false => BadRequest("Tag not part of this group!")
                }
              case None => BadRequest(s"No group found for user ${request.user.uuid}")
            }
        }
      case None => BadRequest(s"No tag found with id $tagId")
    }
  }
}

