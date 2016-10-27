package gg.climb.commons.dbhandling

import java.util.concurrent.TimeUnit

import gg.climb.lolobjects.RiotId
import gg.climb.lolobjects.esports.Player
import gg.climb.lolobjects.game.state.{Blue, Red}
import gg.climb.lolobjects.game.{GameData, MetaData}
import org.mongodb.scala.MongoClient
import org.scalatest.{Matchers, WordSpec}

import scala.concurrent.duration.Duration

class DataAccessHandlerTest extends WordSpec with Matchers {

  type Game = (GameData, MetaData)

  val TIMEOUT = Duration(30, TimeUnit.SECONDS)
  val mongoClient: MongoClient = MongoClient("mongodb://localhost")
  val mdbh = new MongoDbHandler(mongoClient)

  val pdbh = new PostgresDbHandler (
    sys.props("climb.test.pgHost"),
    sys.props("climb.test.pgPort").toInt,
    sys.props("climb.test.pgDbName"),
    sys.props("climb.test.pgUserName"),
    sys.props("climb.test.pgPassword")
  )

  val dah = new DataAccessHandler(pdbh, mdbh)

  "A DataAccessHandler" should {
    "Create Game " in {
      val gameKey = new RiotId[GameData]("1001750032")
      val game: Game = dah.createGame(gameKey)
      val gameData = game._1
      assert(gameData.teams(Blue).playerStates.keys.size == 5)
      assert(gameData.teams(Red).playerStates.keys.size == 5)
      gameData.teams(Blue).playerStates.filter{case (p,b) => p.riotId.equals(new RiotId[Player]("483"))}
        .foreach{ case( player , behavior) =>
        val state1 = gameData.teams(Blue).playerStates(player)(Duration(27498, TimeUnit.MILLISECONDS))
        assert(state1.location.x == 8497.0 && state1.location.y == 10527.0)
      }
    }
  }
}
