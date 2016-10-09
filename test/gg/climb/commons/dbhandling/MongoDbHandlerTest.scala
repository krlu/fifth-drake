package gg.climb.commons.dbhandling

import java.util.concurrent.TimeUnit

import gg.climb.lolobjects.RiotId
import gg.climb.lolobjects.game.state.GameState
import gg.climb.lolobjects.game.{Game, GameIdentifier}
import org.mongodb.scala.MongoClient
import org.scalatest.{Matchers, WordSpec}

import scala.concurrent.Await
import scala.concurrent.duration.Duration

class MongoDbHandlerTest extends WordSpec with Matchers {
  val TIMEOUT = Duration(30, TimeUnit.SECONDS)
  val pdbh = new PostgresDbHandler("localhost", 5432, "league_analytics", "kenneth", "asdfasdf")
  val mongoClient: MongoClient = MongoClient("mongodb://localhost")

  val dbh = new MongoDbHandler(pdbh, mongoClient)
  "A MongoDbHandler " should {

    "query states of a game" in {
      val gameKey = new RiotId[Game]("1001710092")
      val gid: GameIdentifier =  Await.result(dbh.getGIDByRiotId(gameKey), TIMEOUT).get
      val gameStates = Await.result(dbh.getCompleteGame(gid.gameKey), TIMEOUT)
      assert(gameStates.size == 394)
      gameStates.foreach(gameState => {
        assert(gameState.players.size == 10)
        assert(gameState.teams.size == 2)
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
      assert(Await.result(dbh.getAllGames, TIMEOUT).size == 9)
    }
  }

}
