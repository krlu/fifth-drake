package gg.climb.fifthdrake.lolobjects

class RiotId[T](val id: String) {
  override def toString: String = s"RiotId:$id"

  override def equals(other: Any): Boolean = {
    other match {
      case riotId: RiotId[T] => this.id.equals(riotId.id)
      case _ => false
    }
  }

  override def hashCode: Int = id.hashCode
}
