package gg.climb.lolobjects.game.state

import gg.climb.lolobjects.RiotId
import gg.climb.lolobjects.game.Champion

class ChampionState(hp: Double,
                    mp: Double,
                    xp: Double,
                    name: String)

object ChampionState {
	def apply(hp: Double,
	          mp: Double,
	          xp: Double,
	          name: String) = new ChampionState(hp, mp, xp, name)
}

