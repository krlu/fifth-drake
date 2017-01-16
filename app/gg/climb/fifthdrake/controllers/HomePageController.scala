package gg.climb.fifthdrake.controllers

import play.api.mvc.{Action, AnyContent, Controller, Cookie}

/**
  * Created by michael on 1/15/17.
  */
class HomePageController extends Controller {

  def loadLandingPage: Action[AnyContent] = Action {
    Ok(views.html.landingPage())
  }

  def getIdCookie(id: String): Action[AnyContent] = Action {
    Ok("").withCookies(Cookie("G_AUTH_USER_TOKEN", id))
  }
}
