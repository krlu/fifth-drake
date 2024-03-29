package gg.climb.fifthdrake.lolobjects.game.state

import gg.climb.fifthdrake.lolobjects.RiotId
import gg.climb.fifthdrake.lolobjects.esports.Player

class PlayerState(val id: RiotId[Player],
                  val championState: ChampionState,
                  val location: LocationData,
                  val kills: Int,
                  val deaths: Int,
                  val assists: Int,
                  val currentGold: Int,
                  val totalGold: Int,
                  val participantId: Int
                  ) {

  override def toString: String = s"PlayerState(RiotId=$id,\nchampionState=$championState,\nlocation=$location)"
}

