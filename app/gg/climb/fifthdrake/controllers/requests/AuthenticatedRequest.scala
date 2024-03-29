package gg.climb.fifthdrake.controllers.requests

import gg.climb.fifthdrake.browser.UserId
import gg.climb.fifthdrake.controllers.routes
import gg.climb.fifthdrake.dbhandling.DataAccessHandler
import gg.climb.fifthdrake.lolobjects.accounts.User
import play.api.Logger
import play.api.mvc.Results._
import play.api.mvc._

import scala.concurrent.Future

/**
  * Created by michael on 1/18/17.
  */
class AuthenticatedRequest[A](val user: User, request: Request[A]) extends WrappedRequest[A](request)

class AuthenticatedAction(dbh: DataAccessHandler) extends ActionBuilder[AuthenticatedRequest] {
  override def invokeBlock[A](request: Request[A],
                              block: (AuthenticatedRequest[A]) => Future[Result]): Future[Result] = {
    val userId = request.session.get(UserId.name)
    val defaultResult = Future.successful(
      Redirect(routes.HomePageController.loadLandingPage()).withSession(request.session - UserId.name)
    )

    userId match {
      case Some(id) => {
        dbh.getUserByGoogleId(id) match {
          case Some(user) =>
            Logger.info(s"user account successfully logged in: $id\nrequest: ${request.toString()}")
            block(new AuthenticatedRequest[A](user, request))
          case None =>
            Logger.info(s"user account not found: $id\nrequest: ${request.toString()}")
            defaultResult
        }
      }
      case None =>
        Logger.info(s"no user logged in while trying to authenticate: ${request.toString()}")
        defaultResult
    }
  }
}

class AuthorizationFilter(dbh: DataAccessHandler) extends ActionFilter[AuthenticatedRequest] {
  override protected def filter[A](request: AuthenticatedRequest[A]): Future[Option[Result]] = Future.successful {
    dbh.isUserAuthorized(request.user.userId) match {
      case Some(true) =>
        Logger.info(s"user [${request.user.userId}] is authorized: ${request.toString()}")
        None
      case _ =>
        Logger.info(s"user [${request.user.userId}] is not authorized: ${request.toString()}")
        Some(Unauthorized("You are not authorized to access this URL"))
    }
  }
}
