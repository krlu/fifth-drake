package gg.climb.lolobjects.esports

import gg.climb.lolobjects.RiotId

/**
 * Represents a physical team such as TSM or CLG.
 */
class Team(val riotId: RiotId[Team],
           val name: String,
           val acronym: String,
           val players: Traversable[Player]){
  override def toString = s"riotId=$riotId, name=$name, acronym=$acronym, players=$players"
}


object Team{
  def apply(riotId: RiotId[Team],
            name: String, acronym:
            String, players: Traversable[Player]) = new Team(riotId, name, acronym, players)
}
