package gg.climb.fifthdrake.controllers.requests

import gg.climb.fifthdrake.browser.UserId
import gg.climb.fifthdrake.controllers.routes
import gg.climb.fifthdrake.dbhandling.DataAccessHandler
import play.api.Logger
import play.api.mvc.Results._
import play.api.mvc._

import scala.concurrent.Future

/**
  * Created by michael on 1/18/17.
  */
class AuthenticatedRequest[A](val firstName: String,
                              val lastName: String,
                              val email: String,
                              request: Request[A]) extends WrappedRequest[A](request)

class AuthenticatedAction(dbh: DataAccessHandler) extends ActionBuilder[AuthenticatedRequest] {
  override def invokeBlock[A](request: Request[A],
                              block: (AuthenticatedRequest[A]) => Future[Result]): Future[Result] = {
    Logger.debug(s"authenticating request: ${request.toString()}")

    val userId = request.session.get(UserId.name)
    val loggedIn = userId.map(id => dbh.isUserLoggedIn(id))
    val userInfo = userId.map(id => dbh.getPartialUserAccount(id))

    (userId, loggedIn, userInfo) match {
      case (_, Some(true), Some(Some(user))) =>
        block(new AuthenticatedRequest[A](user._1, user._2, user._3, request))
      case (_, _, _) => Future.successful(
        Redirect(routes.HomePageController.loadLandingPage())
          .withSession(request.session - UserId.name)
      )
    }
  }
}

class AuthorizationFilter(dbh: DataAccessHandler) extends ActionFilter[AuthenticatedRequest] {
  override protected def filter[A](request: AuthenticatedRequest[A]): Future[Option[Result]] = Future.successful {
    Logger.debug(s"authorizing request: ${request.toString()}")

    val userId = request.session.get(UserId.name)
    val authorized = userId.map(id => dbh.isUserAuthorized(id))

    authorized match {
      case Some(true) => None
      case _ => Some(Unauthorized("You are not authorized to access this URL"))
    }
  }
}
