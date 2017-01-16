package gg.climb.fifthdrake.controllers

import play.api.mvc.{Action, AnyContent, Controller}

/**
  * Created by michael on 1/15/17.
  */
class HomePageController extends Controller {

  def loadLandingPage: Action[AnyContent] = Action {
    Ok(views.html.landingPage())
  }

}
