package gg.climb.lolobjects.esports

import gg.climb.lolobjects.RiotId

class Player(riotId: RiotId[Player],
             ign: String,
             role: Role,
             team: String)

object Player{
	def apply(riotId: RiotId[Player], ign: String, role: Role, team : String) = new Player(riotId, ign, role, team)
}
