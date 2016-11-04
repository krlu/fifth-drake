package gg.climb.lolobjects.esports

import gg.climb.lolobjects.{InternalId, RiotId}

class Player(val id: InternalId[Player],
             val ign: String,
             val role: Role,
             val riotId: RiotId[Player]) {

  override def toString: String = s"Player(id=$id, ign=$ign, role=$role, riotId=$riotId)"

  override def equals(other: Any): Boolean = other match {
    case that: Player => id == that.id
    case _ => false
  }
  override def hashCode: Int = id.hashCode
}
