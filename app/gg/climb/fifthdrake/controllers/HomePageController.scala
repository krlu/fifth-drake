package gg.climb.fifthdrake.controllers

import gg.climb.fifthdrake.browser.GoogleAuthToken
import play.api.mvc.{Action, AnyContent, Controller, DiscardingCookie, Cookie}

/**
  * Created by michael on 1/15/17.
  */
class HomePageController extends Controller {

  def loadLandingPage: Action[AnyContent] = Action { request =>
    if (request.cookies.get(GoogleAuthToken.name).isDefined) {
      Redirect(routes.HomePageController.loadHomePage())
    } else {
      Ok(views.html.landingPage())
    }
  }

  def loadHomePage: Action[AnyContent] = Action { request =>
    val token = request.cookies.get(GoogleAuthToken.name)

    token.map( t =>
      if (verifyGoogleAuthToken(t.value)) {
        Ok("Home Page")
      } else {
        Redirect(routes.HomePageController.loadLandingPage()).discardingCookies(DiscardingCookie(GoogleAuthToken.name))
      }
    ).getOrElse(
      Redirect(routes.HomePageController.loadLandingPage())
    )
  }

  def authenticateUser: Action[AnyContent] = Action { request =>
    val token: Option[String] = for {
      form: Map[String, Seq[String]] <- request.body.asFormUrlEncoded
      token <- Some(form(GoogleAuthToken.name).head)
    } yield token

    token.map( t =>
      if (verifyGoogleAuthToken(t)) {
        Redirect(routes.HomePageController.loadLandingPage()).withCookies(Cookie(GoogleAuthToken.name, t))
      } else {
        BadRequest("Invalid Google Auth Token").discardingCookies(DiscardingCookie(GoogleAuthToken.name))
      }
    ).getOrElse(
      BadRequest("Missing Google Auth Token")
    )
  }

  def verifyGoogleAuthToken(token: String): Boolean = {
    true
  }
}
