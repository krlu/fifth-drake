package gg.climb.lolobjects.esports

import gg.climb.lolobjects.RiotId

class Player(val riotId: RiotId[Player],
						 val ign: String,
						 val role: Role,
						 val team: String)  {

	override def toString = s"Player(riotId=$riotId, ign=$ign, role=$role, team=$team)"
}

object Player{
	def apply(riotId: RiotId[Player], ign: String, role: Role, team : String) = new Player(riotId, ign, role, team)
}
