package gg.climb.lolobjects.game.state

import scala.concurrent.duration.Duration

class GameState(val timestamp: Duration,
								val red : TeamState,
								val blue : TeamState)  {

	override def toString = s"GameState(timestamp=$timestamp,\nred=$red,\nblue=$blue)"
}

object GameState {
	def apply(timestamp: Duration,
	          red : TeamState,
	          blue : TeamState) = new GameState(timestamp, red, blue)
}
