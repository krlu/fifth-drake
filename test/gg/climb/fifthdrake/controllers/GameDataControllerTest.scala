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
        playersData= team.as[JsArray]
        player <- playersData.value
        playerData = player.as[JsObject]
        playerStates <- playerData.value.get("playerStates")
        stateAtTime <- playerStates.as[JsArray].value
        stateAtTimeData = stateAtTime.as[JsObject]
        championStateJson = stateAtTimeData.value("championState").as[JsObject]
      }{
        assert(playersData.value.size == 5)
        assert(playerData.keys == Set("side", "role", "ign", "championName", "playerStates"))
        assert(stateAtTimeData.keys == Set("position", "championState"))
        assert(championStateJson.keys == Set("hp", "mp", "xp"))
      }
    }
  }
}
