package gg.climb.reasoning

import java.util.concurrent.TimeUnit

import gg.climb.commons.dbhandling.{DataAccessHandler, MongoDbHandler, PostgresDbHandler}
import gg.climb.lolobjects.RiotId
import gg.climb.lolobjects.game.{GameData, MetaData}
import gg.climb.ramenx.core.ListEventStream
import org.mongodb.scala.MongoClient
import org.scalatest.{Matchers, WordSpec}

import scala.concurrent.duration.Duration


class EventFinderTest extends WordSpec with Matchers {

  type Game = (GameData, MetaData)

  val TIMEOUT = Duration(30, TimeUnit.SECONDS)
  val mongoClient: MongoClient = MongoClient("mongodb://localhost")
  val mdbh = new MongoDbHandler(mongoClient)

  // TODO: hardcoded
  val pdbh = new PostgresDbHandler("localhost", 5432, "league_analytics", "kenneth", "asdfasdf")

  val dah = new DataAccessHandler(pdbh, mdbh)

  "An EventTagger " should {
    val ef = new EventFinder()
    "tag events appropriately " in {
      val gameKey = new RiotId[GameData]("1001750032")
      val (gameData, metaData): Game = dah.createGame(gameKey)
      val events: ListEventStream[Duration, Set[GameEvent]] = ef.getAllEventsForGame(gameData, metaData)
      assert(events.size == metaData.gameDuration.toSeconds.toInt)
    }
  }
}
