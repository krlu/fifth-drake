package gg.climb.lolobjects.game.state

import gg.climb.lolobjects.esports.Player
import gg.climb.lolobjects.game.LocationData

class PlayerState(player: Player,
                  championState: ChampionState,
                  location: LocationData)

object PlayerState {
	def apply(player: Player,
	          championState: ChampionState,
	          location: LocationData) = new PlayerState(player, championState, location)
}
