package gg.climb.lolobjects.esports

import gg.climb.lolobjects.{InternalId, RiotId}

class Player(internalId: InternalId[Player],
             riotId: RiotId[Player],
             firstName: String,
             lastName: String,
             ign: String,
             role: Role,
             region: String,
             teamId: Option[InternalId[Team]],
             teamIds: Traversable[InternalId[Team]])
