package gg.climb.fifthdrake.controllers.requests

import java.util.Collections

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken.Payload
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport
import com.google.api.client.json.jackson2.JacksonFactory
import com.typesafe.config.ConfigFactory
import gg.climb.fifthdrake.browser.GoogleAuthToken
import play.api.mvc.Results.Forbidden
import play.api.mvc._

import scala.concurrent.Future

/**
  * Created by michael on 1/18/17.
  */
class AuthenticatedRequest[A](val userInfo: Option[Payload], request: Request[A]) extends WrappedRequest[A](request)

object Authenticated extends ActionBuilder[AuthenticatedRequest] {
  private val conf = ConfigFactory.load()
  lazy val googleClientId: String = conf.getString("climb.googleClientId")
  lazy val authorizedUsersFilePath: String = conf.getString("climb.authorizedUsers")

  override def invokeBlock[A](request: Request[A],
                              block: (AuthenticatedRequest[A]) => Future[Result]): Future[Result] = {

    def verifyGoogleAuthToken(token: String): Option[Payload] = {
      val transport = GoogleNetHttpTransport.newTrustedTransport
      val jsonFactory = JacksonFactory.getDefaultInstance
      val verifier = new GoogleIdTokenVerifier.Builder(transport, jsonFactory)
        .setAudience(Collections.singletonList(googleClientId))
        .build()

      Option(verifier.verify(token))
        .map(t =>
          t.getPayload
        )
    }

    request.cookies
      .get(GoogleAuthToken.name)
      .map(cookie => verifyGoogleAuthToken(cookie.value))
      .map(payload => block(new AuthenticatedRequest[A](payload, request)))
      .getOrElse(Future.successful(Forbidden("Not Authenticated")))
  }
}

object AuthorizationFilter extends ActionFilter[AuthenticatedRequest] {
  override protected def filter[A](request: AuthenticatedRequest[A]): Future[Option[Result]] = Future.successful {
    def verifyUserPermission(email: String): Boolean = {
      val allowedEmails = scala.io.Source.fromFile(Authenticated.authorizedUsersFilePath).getLines()
      allowedEmails.contains(email)
    }

    request.userInfo
      .map(payload => payload.getEmail)
      .map(email => {
        if (verifyUserPermission(email)) {
          None
        } else {
          Some(Forbidden("Not Authorized"))
        }
      }).getOrElse(Some(Forbidden("Not Authenticated")))
  }
}
