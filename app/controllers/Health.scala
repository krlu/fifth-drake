package controllers

import play.api.mvc.{Action, Controller}

/**
	* Created by prasanth on 10/8/16.
	*/
class Health extends Controller {
	def check = Action {
		Ok(BuildInfo.toJson)
	                   }
}
