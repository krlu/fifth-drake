package gg.climb.ramenx

import scalaz.Monoid

class ListBehavior[Time, A](initial: Time => A, fs: List[(Time, Time => A)])
                            (implicit ordering: Ordering[Time])
  extends Behavior[Time, A] {
  import ordering._

  def this(f: Time => A)(implicit ordering: Ordering[Time]) = this(f, Nil)

  val current: Time => A = initial
  val next: Option[(Time, ListBehavior[Time, A])] = fs match {
    case Nil => None
    case x::xs => Some((x._1, new ListBehavior[Time, A](x._2, xs)))
  }

  override def apply(t: Time): A = {
    def getVal(listBehavior: ListBehavior[Time, A]) : Time => A = listBehavior.next match {
        case None => listBehavior.current
        case Some((t2, _)) if t < t2 => listBehavior.current
        case Some((_, behavior)) => getVal(behavior)
      }
    getVal(this)(t)
  }

  override def map[B](f: (A) => B): ListBehavior[Time, B] = new ListBehavior[Time, B](f.compose[Time](current))

  override def sampledBy(start: Time, increment: Time, end: Time)(implicit m: Monoid[Time]): EventStream[Time, A] = {
    def sample(current: Time): List[(Time, A)] = if (ordering.gteq(current, end)) {
      List((current, this (current)))
    } else {
      (current, this (current)) :: sample(m.append(current, increment))
    }
    new ListEventStream[Time, A](sample(start))
  }

  /**
    * @param prev - computes t1 - t2
    * @return
    */
  override def withPrev(diff: Time, prev: (Time, Time) => Time)
                       (implicit m: Monoid[Time]): Behavior[Time, (Option[A], A)] = {
    new ListBehavior[Time, (Option[A], A)](t => if (ordering.lt(prev(t, diff), m.zero)) {
      (None, this (t))
    } else {
      (Some(this (prev(t, diff))), this (t))
    })
  }

  override def zip[B](other: Behavior[Time, B]): Behavior[Time, (A, B)] = {
    new ListBehavior[Time, (A, B)](t => (this(t), other(t)))(ordering)
  }
}

object ListBehavior {
  def always[Time, A](x: A)(implicit ordering: Ordering[Time]): Behavior[Time, A] =
    new ListBehavior[Time, A](_ => x)(ordering)
}
