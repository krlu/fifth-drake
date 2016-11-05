package gg.climb.fifthdrake.dbhandling

import java.util.concurrent.TimeUnit

import gg.climb.fifthdrake.Game
import gg.climb.fifthdrake.lolobjects.RiotId
import gg.climb.fifthdrake.lolobjects.esports.Player
import gg.climb.fifthdrake.lolobjects.game.state.{Blue, Red}
import org.mongodb.scala.MongoClient
import org.scalatest.{Matchers, WordSpec}

import scala.concurrent.duration.Duration

class DataAccessHandlerTest extends WordSpec with Matchers {

  val TIMEOUT = Duration(30, TimeUnit.SECONDS)
  val mongoClient: MongoClient = MongoClient("mongodb://localhost")
  val mdbh = new MongoDbHandler(mongoClient)

  val pdbh = new PostgresDbHandler (
    sys.props("climb.pgHost"),
    sys.props("climb.pgPort").toInt,
    sys.props("climb.pgDbName"),
    sys.props("climb.pgUserName"),
    sys.props("climb.pgPassword")
  )

  val dah = new DataAccessHandler(pdbh, mdbh)

  "A DataAccessHandler" should {
    "Create Game " in {
      val gameKey = new RiotId[Game]("1001750032")
      val (_, gameData) = dah.createGame(gameKey)
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