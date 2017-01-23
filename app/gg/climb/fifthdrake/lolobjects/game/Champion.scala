package gg.climb.fifthdrake.lolobjects.game

import gg.climb.fifthdrake.lolobjects.{InternalId, RiotId}

/**
  * A class that represents a champion in League.
  */
class Champion(val internalId: InternalId[Champion],
               val riotId: RiotId[Champion],
               val name: String,
               val key: String,
               val stats: ChampionStats,
               val image: ChampionImage) {

  override def toString: String = s"Champion(internalId=${internalId.id}, " +
    s"riotId=${riotId.id}, name=$name, key=$key, stats=$stats, image=$image)"
}
