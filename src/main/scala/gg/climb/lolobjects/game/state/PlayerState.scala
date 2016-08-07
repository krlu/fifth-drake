package gg.climb.lolobjects.game.state

import gg.climb.lolobjects.esports.Player
import gg.climb.lolobjects.game.LocationData

class PlayerState(val player: Player,
									val championState: ChampionState,
									val location: LocationData,
									val sideColor: SideColor.Value)  {

	override def toString = s"PlayerState(player=$player," +
		s"\nchampionState=$championState,\nlocation=$location,\nside=$sideColor)"
}

object PlayerState {
	def apply(player: Player,
	          championState: ChampionState,
	          location: LocationData,
	          sideColor: SideColor.Value) = new PlayerState(player, championState, location, sideColor)
}
