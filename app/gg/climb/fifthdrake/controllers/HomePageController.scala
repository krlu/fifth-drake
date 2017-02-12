package gg.climb.fifthdrake.controllers

import gg.climb.fifthdrake.browser.UserId
import gg.climb.fifthdrake.controllers.requests.AuthenticatedAction
import gg.climb.fifthdrake.dbhandling.DataAccessHandler
import play.api.Logger
import play.api.mvc.{Action, AnyContent, Controller}

/**
  * Serves landing page and user home page
  * Stores user account information upon first log in
  *
  * Created by michael on 1/15/17.
  */
class HomePageController(dbh: DataAccessHandler) extends Controller {

  def loadLandingPage: Action[AnyContent] = Action { request =>
    Logger.info("loading landing page")
    Ok(views.html.landingPage(AuthenticatedAction.googleClientId))
  }

  def loadHomePage: Action[AnyContent] = AuthenticatedAction { request =>
    Logger.info("loading home page")
    Ok(s"${request.userInfo.get("given_name")}'s Home Page")
  }

  def logIn(): Action[AnyContent] = Action { request =>
    Logger.info("saving user account information upon log in")

    val form = request.body.asFormUrlEncoded
    val code = form.map(f => f("code").head)

    Logger.info(s"body: $form")

    (form, code) match {
      case (_, Some(c)) =>
        val tokenResponse = AuthenticatedAction.exchangeAuthorizationCode(c, "postmessage")
        val accessToken = tokenResponse.getAccessToken
        val refreshToken = tokenResponse.getRefreshToken
        val idToken = tokenResponse.parseIdToken()
        val payload = idToken.getPayload
        dbh.storeUserAccount(accessToken, refreshToken, payload)
        Ok("").withSession(UserId.name -> payload.getSubject)
      case (_, _) => BadRequest("Missing authorization code")
    }
  }
}
