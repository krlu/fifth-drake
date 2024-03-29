package gg.climb.fifthdrake.lolobjects.esports

import gg.climb.fifthdrake.lolobjects.InternalId

/**
  * Represents a physical team such as TSM or CLG.
  */
class Team(val id: InternalId[Team],
           val name: String,
           val acronym: String,
           val players: Traversable[Player]) {

  override def toString: String = s"riotId=$id, name=$name, acronym=$acronym, players=$players"
}
