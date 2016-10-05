package gg.climb.lolobjects.game.state

import gg.climb.lolobjects.esports.Player
import gg.climb.lolobjects.game.LocationData

class PlayerState(val player: Player,
                  val championState: ChampionState,
                  val location: LocationData,
                  val sideColor: Side)  {

  override def toString = s"PlayerState(player=$player," +
    s"\nchampionState=$championState,\nlocation=$location,\nside=${sideColor.name})"
}
