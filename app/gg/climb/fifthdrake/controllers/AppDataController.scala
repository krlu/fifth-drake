package gg.climb.fifthdrake.controllers

import java.util.UUID

import gg.climb.fifthdrake.controllers.requests.{AuthenticatedAction, AuthorizationFilter}
import gg.climb.fifthdrake.dbhandling.DataAccessHandler
import gg.climb.fifthdrake.lolobjects.accounts._
import play.Logger
import play.api.libs.json.{JsObject, JsValue, Json, Writes}
import play.api.mvc.{Action, AnyContent, Controller}


/**
  * Created by michael on 3/17/17.
  */
class AppDataController(dbh: DataAccessHandler,
                        AuthenticatedAction: AuthenticatedAction,
                        AuthorizationFilter: AuthorizationFilter) extends Controller {

  private implicit val userWrites = new Writes[User] {
    override def writes(user: User): JsValue = Json.obj(
      "id" -> user.uuid.toString,
      "email" -> user.email,
      "firstName" -> user.firstName,
      "lastName" -> user.lastName
    )
  }


  private implicit val userGroupWrites = new Writes[UserGroup] {
    override def writes(userGroup: UserGroup): JsValue = {
      Json.obj(
        "id" -> userGroup.uuid.toString,
        "users" -> userGroup.users
          .flatMap(uuid => dbh.getUserByUuid(uuid))
          .map(user => Json.toJson(user))
      )
    }
  }

  def loadSettings: Action[AnyContent] =  (AuthenticatedAction andThen AuthorizationFilter) { request =>
    Logger.info(s"loading home page: ${request.toString()}")
    Ok(views.html.userSettings())
  }

  /**
    * Search for users
    *
    * query string parameters:
    * email -> user email (String)
    */
  def findUser: Action[AnyContent] = (AuthenticatedAction andThen AuthorizationFilter) { request =>
    Logger.info(s"searching for users with query string parameters: ${request.queryString}")
    request.queryString
      .get("email")
      .map(emails => dbh.getUserByEmail(emails.head)) match {
      case Some(user) =>
        Ok(Json.toJson(user))
      case None =>
        Ok
    }
  }

  /**
    * Create a new user group with the currently logged in user as the only member
    */
  def createNewUserGroup: Action[AnyContent] = (AuthenticatedAction andThen AuthorizationFilter) { request =>
    dbh.getUserGroupByUser(request.user) match {
      case Some(userGroup) =>
        BadRequest(Json.toJson(userGroup)).flashing("error" -> "already member of a user group")
      case None =>
        println("hi")
        dbh.createUserGroup(request.user)
        val newGroup =  dbh.getUserGroupByUser(request.user).orNull
        dbh.insertPermissionForUser(request.user.uuid, newGroup.uuid, Owner)
        Redirect(routes.AppDataController.getSettingsPageData())
    }
  }

  /**
    * Get the personal data and
    * user group associated with the currently logged in user if it exists
    */
  def getSettingsPageData: Action[AnyContent] = AuthenticatedAction { request =>
    def getSelfUserGroup(user : User): (Option[JsValue], Option[Seq[JsObject]]) =
      dbh.getUserGroupByUser(user) match {
        case Some(userGroup) =>
          val permissions: Seq[(UUID, Permission)] = dbh.getPermissionsForGroup(userGroup.uuid)
          val permJson = permissions.map{case (userId, permission) =>
            Json.obj("userId" -> userId.toString, "level" -> permission.name)
          }
          (Some(Json.toJson(userGroup)), Some(permJson))
        case None => (None, None)
      }
    getSelfUserGroup(request.user) match {
      case (Some(group), Some(permJson)) =>
        Ok(Json.obj("group" -> group, "permissions" -> permJson, "currentUser" -> request.user))
      case _ => Ok
    }
  }

  /**
    * Delete a user group off the face of the earth
    * Only owners can delete user groups!!
    *
    * query string parameters:
    * id -> user group uuid (String)
    */
  def deleteUserGroup(): Action[AnyContent] = (AuthenticatedAction andThen AuthorizationFilter) { request =>
    Logger.info(s"deleting user group with query string parameters: ${request.queryString}")
    request.queryString
      .get("id")
      .map(ids => ids.head) match {
        case Some(id) =>
          val groupUuid = UUID.fromString(id)
          dbh.getUserPermissionForGroup(request.user.uuid, groupUuid) match {
            case Some(Owner) =>
              val perms = dbh.getPermissionsForGroup(groupUuid)
              perms.foreach{ case(userId, perm) =>
                dbh.removePermissionForUser(userId, groupUuid)
              }
              dbh.getTagsWithAuthorizedGroupId(groupUuid).foreach{ tag =>
                tag.id match {
                  case Some(tagId) =>
                    val groupIds = tag.authorizedGroups.map(_.uuid).filter(_ != groupUuid)
                    dbh.updateTagsAuthorizedGroups(groupIds, tagId)
                  case None =>
                    Logger.error(s"adding user to group with query string parameters: ${request.queryString}")
                }
              }
              dbh.deleteUserGroup(groupUuid)
              Ok("Group successfully deleted!")
            case _ => BadRequest("Only owners can delete groups!!")
          }
        case None =>
          BadRequest("error: missing 'id' query string parameter")
      }
    }

  /**
    * Add a user to a user group
    *
    * query string parameters:
    * user -> user uuid (String)
    * group -> group uuid to add user to (String)
    */
  def addUserToGroup(): Action[AnyContent] = (AuthenticatedAction andThen AuthorizationFilter) { request =>
    Logger.info(s"adding user to group with query string parameters: ${request.queryString}")
    val userUuidStr = request.queryString.get("user").map(_.head)
    val userGroupUuidStr = request.queryString.get("group").map(_.head)
    (userUuidStr, userGroupUuidStr) match {
      case (Some(user), Some(group)) =>
        val userUuid = UUID.fromString(user)
        dbh.getUserGroupByUserUuid(userUuid) match {
          case Some(userGroup) => BadRequest("User already member of a user group")
          case _ =>
            dbh.getUserGroupByUuid(UUID.fromString(group)) match {
              case Some(userGroup) =>
                val groupUuid = userGroup.uuid
                // Check if user doing the adding is has admin or owner access
                dbh.getUserPermissionForGroup(request.user.uuid, groupUuid) match {
                  case Some(Member) => BadRequest("Members cannot modify groups!!")
                  case _ =>
                    if (!userGroup.users.contains(userUuid)) {
                      dbh.updateUserGroup(groupUuid, userGroup.users.::(userUuid))
                      dbh.insertPermissionForUser(userUuid, groupUuid, Member)
                    }
                    val newGroup = dbh.getUserGroupByUser(request.user)
                    val permissions = dbh.getPermissionsForGroup(groupUuid)
                    val permJson = permissions.map{case (userId, permission) =>
                      Json.obj("userId" -> userId.toString, "level" -> permission.name)
                    }
                    Ok(Json.obj(
                      "group" -> Json.toJson(newGroup),
                      "permissions" -> Json.toJson(permJson),
                      "currentUser" -> Json.toJson(request.user))
                    )
                }
              case None =>
                Ok
            }
        }
      case (_, _) =>
        BadRequest("error: missing either 'user' or 'group' query string parameters")
    }
  }


  /**
    * Update Users permissions in a group
    * Only owners can do this!
    *
    * query string parameters:
    * user -> user uuid (String)
    * group -> group uuid to add user to (String)
    * level -> Permission level (Owner, Member, Admin)
    */
  def updateUserPermission(): Action[AnyContent] = (AuthenticatedAction andThen AuthorizationFilter) { request =>
    Logger.info(s"adding user to group with query string parameters: ${request.queryString}")
    val userUuidStr = request.queryString.get("user").map(_.head)
    val userGroupUuidStr = request.queryString.get("group").map(_.head)
    val permissionLevelStr = request.queryString.get("level").map(_.head)
    (userUuidStr, userGroupUuidStr, permissionLevelStr) match {
      case (Some(user), Some(group), Some(levelStr)) =>
        dbh.getUserGroupByUuid(UUID.fromString(group)) match {
          case Some(userGroup) =>
            val userUuid = UUID.fromString(user)
            val groupUuid = userGroup.uuid
            dbh.getUserPermissionForGroup(request.user.uuid, groupUuid) match {
              case Some(Owner) =>
                if (userGroup.users.contains(userUuid)) {
                  levelStr match {
                    case "owner" => Logger.error("Illegal attempt to make an owner!!")
                    case "member" => dbh.updateUserPermissionForGroup(userUuid, groupUuid, Member)
                    case "admin" => dbh.updateUserPermissionForGroup(userUuid, groupUuid, Admin)
                  }
                }
                val permissions = dbh.getPermissionsForGroup(groupUuid)
                val permJson = permissions.map{case (userId, permission) =>
                  Json.obj("userId" -> userId.toString, "level" -> permission.name)
                }
                Ok(Json.toJson(permJson))
              case Some(_) => BadRequest("Only owners can change permission levels!")
              case None => BadRequest("Could not find user!")
            }
          case None =>
            Ok
        }
      case (_, _, _) =>
        BadRequest("error: missing either 'user' or 'group' or 'level' query string parameters")
    }
  }

  /**
    * Kick a user out of the club
    *
    * query string parameters:
    * user -> removed user's uuid (String)
    * group -> group uuid of which user is currently a member (String)
    */
  def removeUserFromGroup(): Action[AnyContent] = (AuthenticatedAction andThen AuthorizationFilter) { request =>
    Logger.info(s"removing user from user group with query string parameters: ${request.queryString}")
    def updatePermission(groupUuid : UUID, userUuid: UUID) = dbh.getUserGroupByUuid(groupUuid)match {
      case Some(userGroup) =>
        dbh.removePermissionForUser(userUuid, groupUuid)
        dbh.updateUserGroup(userGroup.uuid, userGroup.users.filter(_ != userUuid))
        val newGroup = dbh.getUserGroupByUser(request.user)
        Ok(Json.toJson(newGroup))
      case None =>
        Ok
    }
    val userUuidStr = request.queryString.get("user").map(_.head)
    val userGroupUuidStr = request.queryString.get("group").map(_.head)
    (userUuidStr, userGroupUuidStr) match {
      case (Some(user), Some(group)) =>
        val groupUuid = UUID.fromString(group)
        val userUuid = UUID.fromString(user)
        val myPermission = dbh.getUserPermissionForGroup(request.user.uuid, groupUuid)
        val theirPermission = dbh.getUserPermissionForGroup(userUuid, groupUuid)
        (myPermission, theirPermission) match {
          case (Some(Admin), Some(Member)) => updatePermission(groupUuid, userUuid)
          case (Some(Owner), Some(Admin) | Some(Member)) => updatePermission(groupUuid, userUuid)
          case (None, _) | (_, None) => BadRequest("Cannot find Users!")
          case _ => BadRequest("Can only remove those of lower rank!")
        }
      case (_, _) =>
        BadRequest("error: missing either 'user' or 'group' query string parameters")
    }
  }
}
