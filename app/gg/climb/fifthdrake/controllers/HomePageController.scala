package gg.climb.fifthdrake.controllers

import gg.climb.fifthdrake.browser.GoogleAuthToken
import gg.climb.fifthdrake.controllers.requests.Authenticated
import play.api.mvc.{Action, AnyContent, Controller, Cookie}

/**
  * Serves landing page and user home page
  * Also handles setting log in cookie
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

  def loadHomePage: Action[AnyContent] = Authenticated { request =>
    Ok(s"${request.userInfo.get.get("given_name")}'s Home Page")
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
}
