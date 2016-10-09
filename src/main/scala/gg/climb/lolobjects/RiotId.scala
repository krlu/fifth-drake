package gg.climb.lolobjects

class RiotId[T](val id: String){
	override def toString = s"RiotId:$id"
  override def equals(other: Any): Boolean = {
    other match {
      case riotId: RiotId[T] => this.id.equals(riotId.id)
      case _ => false
    }
  }
}
