package gg.climb.fifthdrake.lolobjects.game.state

class ChampionState(val hp: Double,
                    val mp: Double,
                    val xp: Double,
                    val name: String) {

  override def toString: String = s"ChampionState(hp=$hp, mp=$mp, xp=$xp, name=$name)"
}
