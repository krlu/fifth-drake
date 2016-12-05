package gg.climb.fifthdrake.lolobjects.game.state

class ChampionState(
  val hp: Double,
  val hpMax: Double,
  val power: Double,
  val powerMax: Double,
  val xp: Double,
  val name: String
) {

  override def toString: String = s"ChampionState(hp=$hp, mp=$power, xp=$xp, name=$name)"
}
