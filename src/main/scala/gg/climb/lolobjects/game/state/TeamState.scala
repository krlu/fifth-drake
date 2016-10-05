package gg.climb.lolobjects.game.state

/**
	* Created by Kenneth on 8/4/2016.
	*/
class TeamState(val players : List[PlayerState],
								val barons : Int,
								val dragons : Int,
								val turrets : Int)  {

	override def toString = s"TeamState(players=$players,\nbarons=$barons,\ndragons=$dragons,\nturrets=$turrets)"
}

