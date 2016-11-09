package gg.climb.fifthdrake.controllers

import org.scalatest.{Matchers, WordSpec}
import play.api.db.Databases
import play.api.libs.json.{JsArray, JsObject, JsValue}

class GameDataControllerTest extends WordSpec with Matchers{

  "A GameDataController" should{
    val database = Databases.inMemory(
      name = "mydatabase",
      urlOptions = Map(
        "MODE" -> "MYSQL"
      ),
      config = Map(
        "logStatements" -> true
      )
    )
    val ctrl = new GameDataController

    "Return JSON of player states" in {
      val data: JsObject = ctrl.getGameData("1001750032")
      assert(data.keys == Set("blueTeam", "redTeam"))
      for{
        team: JsValue <- data.values
        teamData = team.as[JsObject]
        players <- teamData.value.get("playerStats")
        playersData = players.as[JsArray]
        player <- playersData.value
        playerData = player.as[JsObject]
        playerStates <- playerData.value.get("playerStates")
        stateAtTime <- playerStates.as[JsArray].value
        stateAtTimeData = stateAtTime.as[JsObject]
        championStateJson = stateAtTimeData.value("championState").as[JsObject]
      }{
        assert(teamData.keys == Set("playerStats"))
        assert(players.as[JsArray].value.size == 5)
        assert(playerData.keys == Set("side", "role", "ign", "championName", "playerStates"))
        assert(stateAtTimeData.keys == Set("side", "location", "championState"))
        assert(championStateJson.keys == Set("hp", "mp", "xp"))
      }
    }
  }
}
