package gg.climb.ramenx.core

/**
  * Created by prasanth on 7/20/16.
  */
class ListBehavior[time <: Ordered[time], +A](f: time => A) extends Behavior[time, A] {

  val current: time => A = f
  val next: Option[(time, ListBehavior[time, A])] = None

  override def get(t: time): A = {
    def getVal(listBehavior: ListBehavior[time, A]) : time => A = listBehavior.next match {
      case None => listBehavior.current
      case Some((t2, behavior)) if t < t2 => listBehavior.current
      case Some((_, behavior)) => getVal(behavior)
    }
    getVal(this)(t)
  }
}
