package gg.climb.analytics

import java.util.concurrent.TimeUnit

import gg.climb.commons.dbhandling.{MongoDbHandler, PostgresDbHandler}
import gg.climb.lolobjects.RiotId
import gg.climb.lolobjects.game.GameData
import gg.climb.lolobjects.game.state.GameState
import gg.climb.ramenx.core.{EventStream, ListEventStream}
import org.mongodb.scala.MongoClient

import scala.concurrent.Await
import scala.concurrent.duration.Duration

/**
  * Created by michael on 8/4/16.
  */
object EventStreamFactory {
  val pdbh = new PostgresDbHandler("localhost", 5432, "league_analytics", "kenneth", "asdfasdf")
  val mongoClient: MongoClient = MongoClient("mongodb://localhost")
  private val mongoHandler = new MongoDbHandler(mongoClient)

  def gameStateStream(game: RiotId[GameData]): EventStream[Duration, GameState] = {
    val gameStates = Await.result(mongoHandler.getCompleteGame(game),
                                  Duration(5, TimeUnit.SECONDS))
      .map(gs => (gs.timestamp, gs))
      .toList
    new ListEventStream[Duration, GameState](gameStates)
  }
}
