package gg.climb.lolobjects.game.state

import scala.concurrent.duration.Duration

class GameState(timestamp: Duration,
                red : TeamState,
                blue : TeamState)

object GameState {
	def apply(timestamp: Duration,
	          red : TeamState,
	          blue : TeamState) = new GameState(timestamp, red, blue)
}
