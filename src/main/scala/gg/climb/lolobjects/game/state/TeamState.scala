package gg.climb.lolobjects.game.state

/**
	* Created by Kenneth on 8/4/2016.
	*/
class TeamState(players : List[PlayerState],
                barons : Int,
                dragons : Int,
                turrets : Int)

object TeamState {
	def apply(players : List[PlayerState],
	          barons : Int,
	          dragons : Int,
	          turrets : Int) = new TeamState(players, barons, dragons, turrets)
}


