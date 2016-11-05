package gg.climb.fifthdrake.reasoning

import java.util.concurrent.TimeUnit

import gg.climb.fifthdrake.Game
import gg.climb.fifthdrake.dbhandling.{DataAccessHandler, MongoDbHandler, PostgresDbHandler}
import gg.climb.fifthdrake.lolobjects.RiotId
import gg.climb.ramenx.EventStream
import org.mongodb.scala.MongoClient
import org.scalatest.{Matchers, WordSpec}

import scala.concurrent.duration.Duration


class EventFinderTest extends WordSpec with Matchers {

  val TIMEOUT = Duration(30, TimeUnit.SECONDS)
  val mongoClient: MongoClient = MongoClient("mongodb://localhost")
  val mdbh = new MongoDbHandler(mongoClient)

  val pdbh = new PostgresDbHandler(
    sys.props("climb.test.pgHost"),
    sys.props("climb.test.pgPort").toInt,
    sys.props("climb.test.pgDbName"),
    sys.props("climb.test.pgUserName"),
    sys.props("climb.test.pgPassword")
  )

  val dah = new DataAccessHandler(pdbh, mdbh)

  "An EventTagger " should {
    val ef = new EventFinder()
    "tag events appropriately " in {
      val gameKey = new RiotId[Game]("1001750032")
      val game@(metaData, gameData): Game = dah.createGame(gameKey)
      val events: EventStream[Duration, Set[GameEvent]] = ef.getAllEventsForGame(game)
      assert(events.size == metaData.gameDuration.toSeconds.toInt)
    }
  }
}
