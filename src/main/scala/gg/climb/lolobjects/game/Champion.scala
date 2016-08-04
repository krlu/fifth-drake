package gg.climb.lolobjects.game

import gg.climb.lolobjects.{InternalId, RiotId}

/**
 * A class that represents a champion in League.
 */
class Champion(internalId: InternalId[Champion],
               riotId: RiotId[Champion],
               name: String,
               stats: ChampionStats,
               image: ChampionImage)
