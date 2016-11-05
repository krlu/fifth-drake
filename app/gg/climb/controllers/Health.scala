package gg.climb.controllers

import controllers.BuildInfo
import play.api.mvc.{Action, AnyContent, Controller}

/**
  * Created by prasanth on 10/8/16.
  */
class Health extends Controller {
  def check: Action[AnyContent] =
    Action {Ok(BuildInfo.toJson)}
}
