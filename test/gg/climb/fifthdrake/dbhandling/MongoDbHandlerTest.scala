package gg.climb.fifthdrake.dbhandling

import java.util.concurrent.TimeUnit

import gg.climb.fifthdrake.Game
import gg.climb.fifthdrake.lolobjects.RiotId
import gg.climb.fifthdrake.lolobjects.game.state.GameState
import org.mongodb.scala.MongoClient
import org.scalatest.{Matchers, WordSpec}

import scala.concurrent.Await
import scala.concurrent.duration.Duration

class MongoDbHandlerTest extends WordSpec with Matchers {
  val TIMEOUT = Duration(30, TimeUnit.SECONDS)
  val mongoClient: MongoClient = MongoClient("mongodb://localhost")

  val dbh = new MongoDbHandler(mongoClient)
  "A MongoDbHandler " should {

    "query states of a game" in {
      val gameKey = new RiotId[Game]("1001710092")
      val gameStates = Await.result(dbh.getCompleteGame(gameKey), TIMEOUT)
      assert(gameStates.size == 394)
      gameStates.foreach(gameState => {
        assert(gameState.blue._2.size == 5)
        assert(gameState.red._2.size  == 5)
      })
      val start = Duration(1780000, TimeUnit.MILLISECONDS)
      val end =  Duration(2000000, TimeUnit.MILLISECONDS)
      val gameWindow: Seq[GameState] = Await.result(dbh.getGameWindow(gameKey,start, end), TIMEOUT)
      gameWindow.foreach(gameState => {
        assert(gameState.timestamp.toMillis >= start.toMillis &&
                 gameState.timestamp.toMillis <= end.toMillis)
      })
      assert(gameWindow.size == 217)
    }

    "query gameIds" in {
      val allGames = Await.result(dbh.getAllGames, TIMEOUT)
      assert(allGames.size == 9)
    }
  }

}