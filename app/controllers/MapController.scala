package controllers

import play.api.mvc._

class MapController extends Controller {

	def getName = Action {
		Ok("Jim")
	}

	def showRequest = Action { request =>
		Ok("Got request [" + request + "]")
	}

}

