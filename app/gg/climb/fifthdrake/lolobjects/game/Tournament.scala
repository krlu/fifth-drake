package gg.climb.fifthdrake.lolobjects.game

import gg.climb.fifthdrake.lolobjects.InternalId

class Tournament(val id : InternalId[Tournament],
                 val year: Int,
                 val split: String,
                 val league: League,
                 val phase: String){

  override def toString: String = s"GameIdentifier(id=$id, year=$year, split=$split, league=$league, phase=$phase)"
}
