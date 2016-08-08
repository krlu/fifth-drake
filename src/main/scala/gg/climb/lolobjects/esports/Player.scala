package gg.climb.lolobjects.esports

import gg.climb.lolobjects.RiotId

class Player(val riotId: RiotId[Player],
						 val ign: String,
						 val role: Role,
						 val team: String)  {

	override def toString = s"Player(riotId=$riotId, ign=$ign, role=$role, team=$team)"

	def canEqual(other: Any): Boolean = other.isInstanceOf[Player]

	override def equals(other: Any): Boolean = other match {
		case that: Player =>
			(that canEqual this) &&
				riotId == that.riotId
		case _ => false
	}
}

object Player{
	def apply(riotId: RiotId[Player], ign: String, role: Role, team : String) = new Player(riotId, ign, role, team)
}
