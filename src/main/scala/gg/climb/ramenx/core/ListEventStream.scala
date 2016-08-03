package gg.climb.ramenx.core

import scalaz.Monoid

class ListEventStream[Time, A](stream: List[(Time, A)])(implicit order: Ordering[Time])
  extends EventStream[Time, A] {

  private val events = stream.sortWith({case ((t1, _), (t2, _)) => order.lt(t1, t2)})

  override def size(): Int = {
    events.size
  }

  override def apply(at: Time): Option[(Time, A)] = {
    events.find(e => e._1.equals(at))
  }

  override def apply(n: Int): (Time, A) = {
    events(n)
  }

  override def getAll(): List[(Time, A)] = events

  override def merge(other: EventStream[Time, A], select: (A, A) => A): EventStream[Time, A] = {
    def mergeList(l1: List[(Time, A)])(l2: List[(Time, A)]): List[(Time, A)] = (l1, l2) match {
      case (Nil, _) => l2
      case (_, Nil) => l1
      case ((t1, x) :: xs, (t2, y) :: ys) if order.lt(t1, t2) => (t1, x) :: mergeList(xs)(l2)
      case ((t1, x) :: xs, (t2, y) :: ys) if order.equiv(t1, t2) =>
        (t1, select(x, y)) :: mergeList(xs)(l2)
      case ((t1, x) :: xs, (t2, y) :: ys) => (t2, y) :: mergeList(l1)(ys)
    }

    new ListEventStream[Time, A](mergeList(events)(other.getAll()))
  }

  override def filter(select: (A) => Boolean): EventStream[Time, A] = {
    new ListEventStream[Time, A](events.filter(e => select(e._2)))
  }

  override def scan[B](initial: B, update: (B, A) => B)
                      (implicit m: Monoid[Time]) : EventStream[Time, B] = {
    val eventsNew: List[(Time, B)] = events.scanLeft(m.zero, initial)({
      case ((t1, v1), (t2, v2)) => (t2, update(v1, v2))
    })
    new ListEventStream[Time, B](eventsNew)
  }

  override def map[B](f: A => B): EventStream[Time, B] = mapWithTime({case (t,v) => f(v)})

  override def mapWithTime[B](f: (Time, A) => B): EventStream[Time, B] =
    new ListEventStream[Time, B](events.map({ case (t, v) => (t, f(t, v))}))
}
