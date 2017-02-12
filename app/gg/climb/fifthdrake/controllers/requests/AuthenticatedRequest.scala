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
    val userId = request.session.get(UserId.name)
    val userInfo = userId.map(id => dbh.getPartialUserAccount(id))

    userInfo match {
      case Some(user) =>
        Logger.info(s"user [${user._3}] is authenticated for: ${request.toString()}")
        block(new AuthenticatedRequest[A](user._1, user._2, user._3, request))
      case None =>
        Logger.info(s"failed to authenticate user for: ${request.toString()}")
        Future.successful(
          Redirect(routes.HomePageController.loadLandingPage())
            .withSession(request.session - UserId.name)
        )
    }
  }
}

class AuthorizationFilter(dbh: DataAccessHandler) extends ActionFilter[AuthenticatedRequest] {
  override protected def filter[A](request: AuthenticatedRequest[A]): Future[Option[Result]] = Future.successful {
    val userId = request.session.get(UserId.name)
    val authorized = userId.map(id => dbh.isUserAuthorized(id))

    authorized match {
      case Some(true) =>
        Logger.info(s"user [${request.email}] is authorized for: ${request.toString()}")
        None
      case _ =>
        Logger.info(s"user [${request.email}] is not authorized for: ${request.toString()}")
        Some(Unauthorized("You are not authorized to access this URL"))
    }
  }
}
