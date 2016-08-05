package gg.climb.analytics

import gg.climb.commons.dbhandling.MongoDBHandler
import gg.climb.lolobjects.game.state.GameState
import gg.climb.ramenx.core.{EventStream, ListEventStream}

import scala.concurrent.duration.Duration

/**
  * Created by michael on 8/4/16.
  */
object EventStreamFactory {
  private val mongoHandler = MongoDBHandler()

  def gameStateStream(game: Int): EventStream[Duration, GameState] = {
    val gameStates = mongoHandler.getCompleteGame(game).map(gs => (gs.timestamp, gs))
    new ListEventStream[Duration, GameState](gameStates)
  }
}
