package gg.climb.lolobjects

class InternalId[T](val id: String) {
  override def toString = s"id=$id"
}

object InternalId{
  def apply[T](id: String) = new InternalId[T](id)
}
