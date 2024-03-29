package gg.climb.fifthdrake.lolobjects.game.state

import gg.climb.fifthdrake.Time

/**
  * Encapsulates time-slice of in-game data at a timestamp t
  */
class GameState(val timestamp: Time,
                val blue: (TeamState, Set[PlayerState]),
                val red: (TeamState, Set[PlayerState])) {

  override def toString: String = s"GameState(timestamp=$timestamp,\nred=$red,\nblue=$blue)"
}

