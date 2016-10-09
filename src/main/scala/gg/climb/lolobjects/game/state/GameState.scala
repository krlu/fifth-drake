package gg.climb.lolobjects.game.state

import scala.concurrent.duration.Duration

class GameState(val timestamp: Duration,
								val red : TeamState,
								val blue : TeamState)  {

	lazy val teams: List[TeamState] = List(blue, red)
	lazy val players: List[PlayerState] = teams.flatMap(ts => ts.players)

	override def toString = s"GameState(timestamp=$timestamp,\nred=$red,\nblue=$blue)"
}

