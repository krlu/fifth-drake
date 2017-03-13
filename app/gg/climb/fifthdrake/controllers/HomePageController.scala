package gg.climb.fifthdrake.controllers

import com.google.api.client.googleapis.auth.oauth2.{GoogleAuthorizationCodeTokenRequest, GoogleTokenResponse}
import com.google.api.client.http.javanet.NetHttpTransport
import com.google.api.client.json.jackson2.JacksonFactory
import gg.climb.fifthdrake.browser.UserId
import gg.climb.fifthdrake.controllers.requests.AuthenticatedAction
import gg.climb.fifthdrake.dbhandling.DataAccessHandler
import gg.climb.fifthdrake.lolobjects.game.{GameIdentifier, MetaData}
import gg.climb.fifthdrake.{GoogleClientId, GoogleClientSecret}
import play.api.Logger
import play.api.libs.json.{JsValue, Json, Writes}
import play.api.mvc.{Action, AnyContent, Controller}

/**
  * Serves landing page and user home page
  * Stores user account information upon first log in
  *
  * Created by michael on 1/15/17.
  */
class HomePageController(dbh: DataAccessHandler,
                         googleClientId: GoogleClientId,
                         googleClientSecret: GoogleClientSecret,
                         AuthenticatedAction: AuthenticatedAction) extends Controller {

  def loadLandingPage: Action[AnyContent] = Action { request =>
    Logger.info(s"loading landing page: ${request.toString()}")
    val userId = request.session.get(UserId.name)
    val validId = userId.map(id => dbh.userExists(id))

    validId match {
      case Some(v) => Ok(views.html.landingPage(googleClientId, v))
      case None => Ok(views.html.landingPage(googleClientId, loggedIn = false))
    }
  }

  def loadHomePage: Action[AnyContent] = AuthenticatedAction { request =>
    Logger.info(s"loading home page: ${request.toString()}")
    Ok(views.html.homePage(googleClientId, true))
  }

  def loadAllGames(): Action[AnyContent] = AuthenticatedAction { request =>
    implicit val metaDataWrites = new Writes[(MetaData, GameIdentifier)] {
      override def writes(o: (MetaData, GameIdentifier)): JsValue = Json.obj(
        "gameLength" -> o._1.gameDuration.toSeconds,
        "blueTeamName" -> o._1.blueTeamName,
        "redTeamName" -> o._1.redTeamName,
        "vodURL" -> o._1.vodURL.toString,
        "gameKey" -> o._1.gameKey.id,
        "gameNumber" -> o._2.gameNumber,
        "timeFrame" -> Json.obj(
          "gameDate" -> o._1.gameDate,
          "week" -> o._2.week,
          "patch" -> o._1.patch),
        "tournament" -> Json.obj(
          "year" -> o._2.tournament.year,
          "split" -> o._2.tournament.split,
          "phase" -> o._2.tournament.phase,
          "league" -> o._2.tournament.league.name)
      )
    }
    val gidMap: Map[String, GameIdentifier] = dbh.getAllGameIdentifiers.map(gid => gid.gameKey.id -> gid).toMap

    val allData: Seq[JsValue] = dbh.getAllGames.map{ md =>
      Json.toJson((md, gidMap(md.gameKey.id)))
    }

    Ok(Json.toJson(allData))
  }

  def logIn(): Action[AnyContent] = Action { request =>
    Logger.info(s"saving user account information upon log in: ${request.toString()}")

    def exchangeAuthorizationCode(code: String, redirectUrl: String): GoogleTokenResponse = {
      new GoogleAuthorizationCodeTokenRequest(
        new NetHttpTransport(),
        JacksonFactory.getDefaultInstance,
        "https://www.googleapis.com/oauth2/v4/token",
        googleClientId,
        googleClientSecret,
        code,
        redirectUrl
      ).execute()
    }

    val form = request.body.asFormUrlEncoded
    val code = form.map(f => f("code").head)

    Logger.info(s"log in form body: $form\nrequest: ${request.toString()}")

    (form, code) match {
      case (_, Some(c)) =>
        val tokenResponse = exchangeAuthorizationCode(c, "postmessage")
        val accessToken = tokenResponse.getAccessToken
        val refreshToken = tokenResponse.getRefreshToken
        val idToken = tokenResponse.parseIdToken()
        val payload = idToken.getPayload
        dbh.storeUser(accessToken, refreshToken, payload)
        Ok("").withSession(UserId.name -> payload.getSubject)
      case (_, _) => BadRequest("Missing authorization code")
    }
  }
}
