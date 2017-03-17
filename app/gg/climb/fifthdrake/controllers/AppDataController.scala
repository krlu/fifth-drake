package gg.climb.fifthdrake.controllers

import java.util.UUID

import gg.climb.fifthdrake.controllers.requests.{AuthenticatedAction, AuthorizationFilter}
import gg.climb.fifthdrake.dbhandling.DataAccessHandler
import gg.climb.fifthdrake.lolobjects.accounts.{User, UserGroup}
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
      "firstName" -> user.firstName,
      "lastName" -> user.lastName,
      "email" -> user.email
    )
  }

  private implicit val userGroupWrites = new Writes[UserGroup] {
    override def writes(userGroup: UserGroup): JsValue = {
      Json.obj(
        "users" -> Json.arr(
          userGroup.users
            .flatMap(uuid => dbh.getUserByUuid(uuid))
            .map(user => Json.toJson(user))
        )
      )
    }
  }

  def createNewUserGroup: Action[AnyContent] = (AuthenticatedAction andThen AuthorizationFilter) { request =>
    dbh.getUserGroup(request.user) match {
      case Some(userGroup) =>
        BadRequest(Json.toJson(userGroup)).flashing("error" -> "already member of a user group")
      case None =>
        dbh.createUserGroup(request.user)
        Redirect(routes.AppDataController.getSelfUserGroup())
    }
  }

  def getSelfUserGroup: Action[AnyContent] = AuthenticatedAction { request =>
    dbh.getUserGroup(request.user) match {
      case Some(userGroup) =>
        Ok(Json.toJson(userGroup))
      case None =>
        Ok("").flashing("error" -> "user is not member of any user group")
    }
  }

  def deleteUserGroup: Action[AnyContent] = ???
  def removeUserFromGroup: Action[AnyContent] = ???
}
