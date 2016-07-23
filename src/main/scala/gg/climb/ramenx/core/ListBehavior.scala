package gg.climb.ramenx.core

class ListBehavior[Time, +A](f: Time => A)(implicit ordering: Ordering[Time])
  extends Behavior[Time, A] {
  import ordering._

  val current: Time => A = f
  val next: Option[(Time, ListBehavior[Time, A])] = None

  override def get(t: Time): A = {
    def getVal(listBehavior: ListBehavior[Time, A]) : Time => A = listBehavior.next match {
        case None => listBehavior.current
        case Some((t2, behavior)) if t < t2 => listBehavior.current
        case Some((_, behavior)) => getVal(behavior)
      }
    getVal(this)(t)
  }

  override def map[B](f: (A) => B) = new ListBehavior[Time, B](f.compose[Time](current))
}

object ListBehavior {
  def always[Time, A](x: A)(implicit ordering: Ordering[Time]): Behavior[Time, A] =
    new ListBehavior[Time, A](_ => x)(ordering)
}
