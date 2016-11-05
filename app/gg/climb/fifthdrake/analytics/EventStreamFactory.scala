package gg.climb.fifthdrake.analytics

import java.util.concurrent.TimeUnit

import gg.climb.fifthdrake.dbhandling.{MongoDbHandler, PostgresDbHandler}
import gg.climb.fifthdrake.lolobjects.RiotId
import gg.climb.fifthdrake.lolobjects.game.state.GameState
import gg.climb.fifthdrake.{Game, Time}
import gg.climb.ramenx.{EventStream, ListEventStream}
import org.mongodb.scala.MongoClient

import scala.concurrent.Await
import scala.concurrent.duration.Duration

/**
  * Created by michael on 8/4/16.
  */
object EventStreamFactory {
  val pdbh = new PostgresDbHandler("localhost", 5432, "league_analytics", "prasanth", "")
  val mongoClient: MongoClient = MongoClient("mongodb://localhost")
  private val mongoHandler = new MongoDbHandler(mongoClient)

  def gameStateStream(game: RiotId[Game]): EventStream[Time, GameState] = {
    val gameStates = Await.result(mongoHandler.getCompleteGame(game),
                                  Duration(5, TimeUnit.SECONDS))
      .map(gs => (gs.timestamp, gs))
      .toList
    new ListEventStream[Time, GameState](gameStates)
  }
}
