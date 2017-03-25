package gg.climb.fifthdrake.controllers

import java.util.UUID

import gg.climb.fifthdrake.controllers.requests.{AuthenticatedAction, AuthorizationFilter}
import gg.climb.fifthdrake.dbhandling.DataAccessHandler
import gg.climb.fifthdrake.lolobjects.accounts.{Member, User, UserGroup}
import play.Logger
import play.api.libs.json.{JsValue, Json, Writes}
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
      "firstName" -> user.firstName,
      "lastName" -> user.lastName,
      "email" -> user.email
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

  def loadSettings: Action[AnyContent] =  AuthenticatedAction { request =>
    Logger.info(s"loading home page: ${request.toString()}")
    Ok(views.html.userSettings())
  }


  /**
    * Search for users
    *
    * query string parameters:
    * email -> user email (String)
    */
  def findUser: Action[AnyContent] = AuthenticatedAction { request =>
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
    println(request.user)
    dbh.getUserGroupByUser(request.user) match {
      case Some(userGroup) =>
        BadRequest(Json.toJson(userGroup)).flashing("error" -> "already member of a user group")
      case None =>
        dbh.createUserGroup(request.user)
        Redirect(routes.AppDataController.getSelfUserGroup())
    }
  }

  /**
    * Get the user group associated with the currently logged in user if it exists
    */
  def getSelfUserGroup: Action[AnyContent] = AuthenticatedAction { request =>
    dbh.getUserGroupByUser(request.user) match {
      case Some(userGroup) =>
        Ok(Json.toJson(userGroup))
      case None =>
        Ok
    }
  }

  /**
    * Delete a user group off the face of the earth
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
          dbh.deleteUserGroup(UUID.fromString(id))
          Ok
        case None =>
          BadRequest.flashing("error" -> "missing 'id' query string parameter")
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
        dbh.getUserGroupByUuid(UUID.fromString(group)) match {
          case Some(userGroup) =>
            val userUuid = UUID.fromString(user)
            val groupUuid = userGroup.uuid
            if (!userGroup.users.contains(userUuid)) {
              dbh.insertPermissionForUser(userUuid, groupUuid, Member)
              dbh.updateUserGroup(groupUuid, userGroup.users.::(userUuid))
            }
            val newGroup = dbh.getUserGroupByUser(request.user)
            Ok(Json.toJson(newGroup))
          case None =>
            Ok
        }
      case (_, _) =>
        BadRequest.flashing("error" -> "missing either 'user' or 'group' query string parameters")
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
    val userUuidStr = request.queryString.get("user").map(_.head)
    val userGroupUuidStr = request.queryString.get("group").map(_.head)
    (userUuidStr, userGroupUuidStr) match {
      case (Some(user), Some(group)) =>
        dbh.getUserGroupByUuid(UUID.fromString(group)) match {
          case Some(userGroup) =>
            dbh.removePermissionForUser(UUID.fromString(user), UUID.fromString(group))
            dbh.updateUserGroup(userGroup.uuid, userGroup.users.filter(_ != UUID.fromString(user)))
            val newGroup = dbh.getUserGroupByUser(request.user)
            Ok(Json.toJson(newGroup))
          case None =>
            Ok
        }
      case (_, _) =>
        BadRequest.flashing("error" -> "missing either 'user' or 'group' query string parameters")
    }
  }
}
