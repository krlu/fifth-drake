package gg.climb.fifthdrake.lolobjects

class InternalId[T](val id: String) {
  override def toString: String = s"InternalId=$id"

  override def equals(other: Any): Boolean = {
    other match {
      case internalId: InternalId[T] => this.id.equals(internalId.id)
      case _ => false
    }
  }

  override def hashCode: Int = id.hashCode
}
