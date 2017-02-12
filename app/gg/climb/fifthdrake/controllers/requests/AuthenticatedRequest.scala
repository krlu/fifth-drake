package gg.climb.fifthdrake.controllers.requests

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken.Payload
import com.google.api.client.googleapis.auth.oauth2.{GoogleAuthorizationCodeTokenRequest, GoogleTokenResponse}
import com.google.api.client.http.javanet.NetHttpTransport
import com.google.api.client.json.jackson2.JacksonFactory
import com.typesafe.config.ConfigFactory
import gg.climb.fifthdrake.{GoogleClientId, GoogleClientSecret}
import play.api.Logger
import play.api.mvc.Results._
import play.api.mvc._

import scala.concurrent.Future

/**
  * Created by michael on 1/18/17.
  */
class AuthenticatedRequest[A](val userInfo: Payload, request: Request[A]) extends WrappedRequest[A](request)

object AuthenticatedAction extends ActionBuilder[AuthenticatedRequest] {
  private val conf = ConfigFactory.load()
  lazy val googleClientId: GoogleClientId = conf.getString("climb.googleClientId")
  lazy val googleClientSecret: GoogleClientSecret = conf.getString("climb.googleClientSecret")

  def exchangeAuthorizationCode(code: String, redirectUrl: String): GoogleTokenResponse = {
    new GoogleAuthorizationCodeTokenRequest(
      new NetHttpTransport(),
      JacksonFactory.getDefaultInstance,
      "https://www.googleapis.com/oauth2/v4/token",
      googleClientId,
      googleClientSecret,
      code,
      redirectUrl
    ).execute()
  }

  override def invokeBlock[A](request: Request[A],
                              block: (AuthenticatedRequest[A]) => Future[Result]): Future[Result] = {
    Logger.debug(s"authenticating request: [Headers] ${request.headers}")
    Future.successful(Ok(""))
  }
}

object AuthorizationFilter extends ActionFilter[AuthenticatedRequest] {

  override protected def filter[A](request: AuthenticatedRequest[A]): Future[Option[Result]] = Future.successful {
    Logger.debug("filtering authenticated request for user authorization")
    Some(Ok(""))
  }
}
