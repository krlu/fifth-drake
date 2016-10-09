package gg.climb.lolobjects.game

import gg.climb.lolobjects.{InternalId, RiotId}

/**
 * A class that represents a champion in League.
 */
class Champion(val internalId: InternalId[Champion],
               val riotId: RiotId[Champion],
               val name: String,
               val stats: ChampionStats,
               val image: ChampionImage){

  override def toString = s"Champion(internalId=${internalId.id}, " +
    s"riotId=${riotId.id}, name=$name, stats=$stats, image=$image)"
}
