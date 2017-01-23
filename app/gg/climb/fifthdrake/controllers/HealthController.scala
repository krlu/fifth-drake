package gg.climb.fifthdrake.controllers

import controllers.BuildInfo
import play.api.mvc.{Action, AnyContent, Controller}

/**
  * Created by prasanth on 10/8/16.
  */
class HealthController extends Controller {
  def check: Action[AnyContent] =
    Action {Ok(BuildInfo.toJson)}
}
