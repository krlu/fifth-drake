package gg.climb.ramenx.core

import scalaz.Monoid

trait Behavior[Time, A] {
  def apply(t : Time) : A
  def map[B](f: A => B): Behavior[Time, B]
  def sampledBy(start: Time, increment: Time, end: Time)(implicit m: Monoid[Time]): EventStream[Time, A]
  def withPrev(prev: Time, diff: (Time, Time) => Time)(implicit m: Monoid[Time]): Behavior[Time, (Option[A], A)]
  def zip[B](other: Behavior[Time, B]): Behavior[Time, (A, B)]
}
object Behavior {
  implicit class Apply[Time, A, B](val behavior: Behavior[Time, A => B]) extends AnyVal {
    def <@>(events: EventStream[Time, A]): EventStream[Time, B] = events.mapWithTime((t, v) => behavior(t)(v))
  }
  implicit class Whenever[Time, A](val behavior: Behavior[Time, A]) extends AnyVal {
    def <@(events: EventStream[Time, _]): EventStream[Time, A] = events.mapWithTime((t, v) => behavior(t))
  }
}
