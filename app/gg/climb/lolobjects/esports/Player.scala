package gg.climb.lolobjects.esports

import gg.climb.lolobjects.InternalId

class Player(val id: InternalId[Player],
             val ign: String,
             val role: Role,
             val team: String) {

  override def toString: String = s"Player(riotId=$id, ign=$ign, role=$role, team=$team)"

  override def equals(other: Any): Boolean = other match {
    case that: Player =>
      (that canEqual this) &&
        id == that.id
    case _ => false
  }

  override def hashCode: Int = id.hashCode

  def canEqual(other: Any): Boolean = other.isInstanceOf[Player]
}
