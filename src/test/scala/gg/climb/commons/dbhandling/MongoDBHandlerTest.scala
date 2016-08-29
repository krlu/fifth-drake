package gg.climb.commons.dbhandling

import java.util.concurrent.TimeUnit

import gg.climb.lolobjects.RiotId
import gg.climb.lolobjects.game.Game
import gg.climb.lolobjects.game.state.GameState
import org.scalatest.{Matchers, WordSpec}

import scala.concurrent.duration.Duration

class MongoDBHandlerTest extends WordSpec with Matchers{
  val dbh = MongoDBHandler()
  "A MongoDBHandler " should {
    "query all teams" in {
      val teams = dbh.getAllTeams()
      assert(teams.size == 33)
      teams.foreach(team => println(team.name + "  " + team.players.size))
    }
    "query states of a game" in {
      val gameKey = RiotId[Game]("1001710092")
      val gameStates: List[GameState] = dbh.getCompleteGame(gameKey)
      assert(gameStates.size == 394)
      gameStates.foreach(gameState => {
        assert(gameState.players.size == 10)
        assert(gameState.teams.size == 2)
      })
      val start = Duration(1780000, TimeUnit.MILLISECONDS)
      val end =  Duration(2000000, TimeUnit.MILLISECONDS)
      val gameWindow: List[GameState] = dbh.getGameWindow(gameKey,start, end)
      gameWindow.foreach(gameState => {
        assert(gameState.timestamp.toMillis >= start.toMillis && gameState.timestamp.toMillis <= end.toMillis)
      })
      assert(gameWindow.size == 217)
    }

    "query gameIds" in {
      assert(dbh.getAllGIDs().size == 9)
    }
  }

}
