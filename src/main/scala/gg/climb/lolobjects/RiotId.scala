package gg.climb.lolobjects

class RiotId[T](val id: String){
	override def toString = s"id:$id"
}

object RiotId {
	def apply[T](id : String) = new RiotId[T](id)
}
