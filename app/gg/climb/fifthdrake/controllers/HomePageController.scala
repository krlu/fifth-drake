package gg.climb.fifthdrake.controllers

import gg.climb.fifthdrake.GoogleClientId
import gg.climb.fifthdrake.browser.GoogleAuthToken
import gg.climb.fifthdrake.controllers.requests.Authenticated
import play.api.Logger
import play.api.mvc.{Action, AnyContent, Controller, Cookie}

/**
  * Serves landing page and user home page
  * Also handles setting log in cookie
  *
  * Created by michael on 1/15/17.
  */
class HomePageController(googleClientId: GoogleClientId) extends Controller {

  def loadLandingPage: Action[AnyContent] = Action { request =>
    Logger.info("loading landing page")
    if (request.cookies.get(GoogleAuthToken.name).isDefined) {
      Logger.debug("redirecting user to home page for token authentication")
      Redirect(routes.HomePageController.loadHomePage())
    } else {
      Logger.debug("sending landing page result")
      Ok(views.html.landingPage(googleClientId))
    }
  }

  def loadHomePage: Action[AnyContent] = Authenticated { request =>
    Logger.info("loading home page")
    Ok(s"${request.userInfo.get("given_name")}'s Home Page")
  }

  def setTokenCookie(): Action[AnyContent] = Action { request =>
    Logger.debug("setting G_AUTH_USER_TOKEN")

    val token: Option[String] = for {
      form: Map[String, Seq[String]] <- request.body.asFormUrlEncoded
      token <- Some(form(GoogleAuthToken.name).head)
    } yield token

    token.map(t => {
      Logger.debug(s"Cookie set with value: $t")
      Redirect(routes.HomePageController.loadHomePage()).withCookies(Cookie(GoogleAuthToken.name, t))
    }).getOrElse({
      Logger.debug("Did not receive a token in form")
      BadRequest("Missing Google Auth Token")
    })
  }
}
