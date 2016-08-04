package gg.climb.lolobjects.esports

import gg.climb.lolobjects.{InternalId, RiotId}

/**
 * Represents a physical team such as TSM or CLG.
 */
class Team(internalId: InternalId[Team],
           riotId: RiotId[Team],
           name: String,
           acronym: String,
           players: Traversable[Player])
