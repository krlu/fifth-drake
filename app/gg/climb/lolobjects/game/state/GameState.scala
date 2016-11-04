package gg.climb.lolobjects.game.state

import scala.concurrent.duration.Duration

/**
  * Encapsulates time-slice of in-game data at a timestamp t
  */
class GameState(val timestamp: Duration,
                val red: (TeamState, Set[PlayerState]),
                val blue: (TeamState, Set[PlayerState])) {

  override def toString: String = s"GameState(timestamp=$timestamp,\nred=$red,\nblue=$blue)"
}

