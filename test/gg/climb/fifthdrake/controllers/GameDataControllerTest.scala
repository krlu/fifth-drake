package gg.climb.fifthdrake.controllers

import gg.climb.fifthdrake.dbhandling.{DataAccessHandler, MongoDbHandler, PostgresDbHandler}
import org.mongodb.scala.MongoClient
import org.scalatest.{Matchers, WordSpec}
import play.api.libs.json.{JsArray, JsObject, JsValue}

class GameDataControllerTest extends WordSpec with Matchers{

  "A GameDataController" should{

    val ctrl = new GameDataController(
      new DataAccessHandler(
        new PostgresDbHandler(
          sys.props("climb.pgHost"),
          sys.props("climb.pgPort").toInt,
          sys.props("climb.pgDbName"),
          sys.props("climb.pgUserName"),
          sys.props("climb.pgPassword")
        ),
        new MongoDbHandler(MongoClient("mongodb://localhost"))
      )
    )

    "Return JSON of player states" in {
      val data: JsObject = ctrl.getGameData("1001750032")
      assert(data.keys == Set("blueTeam", "redTeam"))
      for{
        team: JsValue <- data.values
        teamData = team.as[JsObject]
        player <- teamData.values
        playerData = player.as[JsObject]
        playerStates <- playerData.values
        playerStatesData = playerStates.as[JsArray]
        playerStateAtTime <- playerStatesData.value
        stateAtTimeData = playerStateAtTime.as[JsObject]
        championStateJson = stateAtTimeData.value("championState").as[JsObject]
      }{
        assert(teamData.keys == Set("playerStats"))
        assert(playerData.keys == Set("top", "jungle", "mid", "bot", "support"))
        assert(stateAtTimeData.keys == Set("t", "ign", "side", "location", "championState"))
        assert(championStateJson.keys == Set("championName", "hp", "mp", "xp"))
      }
    }
  }
}