package gg.climb.lolobjects

class RiotId[T](val id: String)

object RiotId {
	def apply[T](id : String) = new RiotId[T](id)
}
