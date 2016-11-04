package gg.climb.lolobjects.game.state

import gg.climb.lolobjects.RiotId
import gg.climb.lolobjects.esports.Player

class PlayerState(val id: RiotId[Player],
                  val championState: ChampionState,
                  val location: LocationData,
                  val sideColor: Side) {

  override def toString: String = s"PlayerState(RiotId=$id,\nchampionState=$championState,\nlocation=$location," +
    s"\nside=${sideColor.name})"
}

