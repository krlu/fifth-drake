package gg.climb.lolobjects.game.state

import gg.climb.lolobjects.esports.Player
import gg.climb.lolobjects.game.LocationData

class PlayerState(val player: Player,
									val championState: ChampionState,
									val location: LocationData)  {

	override def toString = s"PlayerState(player=$player,\nchampionState=$championState,\nlocation=$location)"
}

object PlayerState {
	def apply(player: Player,
	          championState: ChampionState,
	          location: LocationData) = new PlayerState(player, championState, location)
}
