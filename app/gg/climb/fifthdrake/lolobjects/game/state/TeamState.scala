package gg.climb.fifthdrake.lolobjects.game.state

class TeamState(val barons: Int,
                val dragons: Int,
                val turrets: Int) {

  override def toString: String =
    s"TeamState(barons=$barons,dragons=$dragons,turrets=$turrets)"
}
