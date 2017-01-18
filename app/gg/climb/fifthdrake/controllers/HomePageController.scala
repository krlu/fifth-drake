package gg.climb.fifthdrake.controllers

import java.util.Collections

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken.Payload
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport
import com.google.api.client.json.jackson2.JacksonFactory
import gg.climb.fifthdrake.browser.GoogleAuthToken
import play.api.mvc.{Action, AnyContent, Controller, Cookie, DiscardingCookie}

/**
  * Every page that requires authentication must verify token in case of:
  * 1) Fake Token
  * 2) Expired Token
  *
  * HomePageController#verifyGoogleAuthToken handles both of the above cases
  *
  * Created by michael on 1/15/17.
  */
class HomePageController(googleClientId: String) extends Controller {

  def loadLandingPage: Action[AnyContent] = Action { request =>
    if (request.cookies.get(GoogleAuthToken.name).isDefined) {
      Redirect(routes.HomePageController.loadHomePage())
    } else {
      Ok(views.html.landingPage(googleClientId))
    }
  }

  def loadHomePage: Action[AnyContent] = Action { request =>
    request.cookies.get(GoogleAuthToken.name).map( token =>
      verifyGoogleAuthToken(token.value).map( user =>
        Ok(s"<h1>${user.get("given_name")}'s Home Page<h1>")
      ).getOrElse(
        Redirect(routes.HomePageController.loadLandingPage()).discardingCookies(DiscardingCookie(GoogleAuthToken.name))
      )
    ).getOrElse(
      Redirect(routes.HomePageController.loadLandingPage())
    )
  }

  def setTokenCookie(): Action[AnyContent] = Action { request =>
    val token: Option[String] = for {
      form: Map[String, Seq[String]] <- request.body.asFormUrlEncoded
      token <- Some(form(GoogleAuthToken.name).head)
    } yield token

    token.map( t =>
      Redirect(routes.HomePageController.loadHomePage()).withCookies(Cookie(GoogleAuthToken.name, t))
    ).getOrElse(
      BadRequest("Missing Google Auth Token")
    )
  }

  def verifyGoogleAuthToken(token: String): Option[Payload] = {
    val transport = GoogleNetHttpTransport.newTrustedTransport
    val jsonFactory = JacksonFactory.getDefaultInstance
    val verifier = new GoogleIdTokenVerifier.Builder(transport, jsonFactory)
      .setAudience(Collections.singleton(googleClientId))
      .build()

    Option(verifier.verify(token))
      .map( t =>
        t.getPayload
      )
  }
}
