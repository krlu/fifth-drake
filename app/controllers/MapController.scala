package controllers

import akka.util.ByteString
import play.api.http.HttpEntity
import play.api.libs.json.Json
import play.api.mvc._

class MapController extends Controller {

	def getName = Action {
		Ok("Jim")
	}

	def showRequest = Action { request =>
		Ok("Got request [" + request + "]")
	}

	def getGameData(gameId: Int) = Action {
		Ok(Json.obj("id" -> gameId, "dank" -> "meme"))
		//TODO: query climb-core for game data
		//TODO: should be returned as JSON
	}

}

