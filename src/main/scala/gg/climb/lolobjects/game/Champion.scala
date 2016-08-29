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

  override def toString = s"$internalId=$internalId, riotId=$riotId, name=$name, stats=$stats, image=$image"
}

object Champion{
  def apply( internalId: InternalId[Champion],
             riotId: RiotId[Champion],
             name: String,
             stats: ChampionStats,
             image: ChampionImage) = new Champion(internalId, riotId, name, stats, image)
}
