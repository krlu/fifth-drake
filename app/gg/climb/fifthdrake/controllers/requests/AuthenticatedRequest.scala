package gg.climb.fifthdrake.controllers.requests

import java.util.Collections

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken.Payload
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport
import com.google.api.client.json.jackson2.JacksonFactory
import com.typesafe.config.ConfigFactory
import gg.climb.fifthdrake.GoogleClientId
import gg.climb.fifthdrake.browser.GoogleAuthToken
import play.api.Logger
import play.api.mvc.Results.Forbidden
import play.api.mvc._

import scala.concurrent.Future
import scala.io.Source

/**
  * Created by michael on 1/18/17.
  */
class AuthenticatedRequest[A](val userInfo: Payload, request: Request[A]) extends WrappedRequest[A](request)

object Authenticated extends ActionBuilder[AuthenticatedRequest] {
  private val conf = ConfigFactory.load()
  lazy val googleClientId: GoogleClientId = conf.getString("climb.googleClientId")
  lazy val authorizedUsersFilePath: String = conf.getString("climb.authorizedUsers")

  override def invokeBlock[A](request: Request[A],
                              block: (AuthenticatedRequest[A]) => Future[Result]): Future[Result] = {

    Logger.debug(s"authenticating request: [URI] ${request.uri}, [Remote] ${request.remoteAddress}")

    def verifyGoogleAuthToken(token: String): Option[Payload] = {
      Logger.debug(s"verifying Google ID Token: $token")
      val transport = GoogleNetHttpTransport.newTrustedTransport
      val jsonFactory = JacksonFactory.getDefaultInstance
      val verifier = new GoogleIdTokenVerifier.Builder(transport, jsonFactory)
        .setAudience(Collections.singletonList(googleClientId))
        .build()

      Option(verifier.verify(token)).map(t => t.getPayload)
    }

    val cookie = request.cookies.get(GoogleAuthToken.name)
    val payload = cookie.flatMap(c => verifyGoogleAuthToken(c.value))

    (cookie, payload) match {
      case (None, _) => {
        Logger.debug("G_AUTH_TOKEN_ID cookie is missing")
        Future.successful(Forbidden("Not Logged In"))
      }
      case (_, None) => {
        Logger.debug("Google returned null payload due to invalid token")
        Future.successful(Forbidden("Invalid Authentication"))
      }
      case (_, Some(p)) => {
        Logger.debug(s"user payload: $p")
        block(new AuthenticatedRequest[A](p, request))
      }
    }
  }
}

object AuthorizationFilter extends ActionFilter[AuthenticatedRequest] {

  override protected def filter[A](request: AuthenticatedRequest[A]): Future[Option[Result]] = Future.successful {

    Logger.debug("filtering authenticated request for user authorization")

    def verifyUserPermission(email: String): Boolean = {
      Logger.debug(s"verifying authorization for user: $email")
      Source.fromFile(Authenticated.authorizedUsersFilePath)
        .getLines()
        .contains(email)
    }

   if (verifyUserPermission(request.userInfo.getEmail)) {
     Logger.debug("user is authorized")
     None
   } else {
     Logger.debug("user is not authorized")
     Some(Forbidden("Not Authorized"))
   }
  }
}
