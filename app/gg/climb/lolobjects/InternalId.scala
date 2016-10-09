package gg.climb.lolobjects

class InternalId[T](val id: String) {
  override def toString = s"InternalId=$id"
  override def equals(other: Any): Boolean = {
    other match {
      case internalId: InternalId[T] => this.id.equals(internalId.id)
      case _ => false
    }
  }
}
