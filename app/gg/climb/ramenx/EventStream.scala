package gg.climb.ramenx

import scalaz.Monoid

trait EventStream[Time, A] {
  def size: Int
  def apply(at: Time): Option[(Time, A)]
  def apply(n: Int): (Time, A)
  def first: (Time, A)
  def last: (Time, A)
  def getAll: List[(Time, A)]
  def merge(stream: EventStream[Time, A], select: (A, A) => A): EventStream[Time, A]
  def filter(select: A => Boolean): EventStream[Time, A]
  def scan[B](initial: B, update: (B, A) => B)(implicit m: Monoid[Time]): EventStream[Time, B]
  def map[B](f: A => B): EventStream[Time, B]
  def mapWithTime[B](f: (Time, A) => B): EventStream[Time, B]
  def toBehavior(initial: (Time, A), last: (Time, A))
                (convert: ((Time, A), (Time, A)) => Time => A): Behavior[Time, A]
  def stepper(initial: (Time, A), last: (Time, A)): Behavior[Time, A] =
    toBehavior(initial, last)({case ((_, v), _) => Function.const(v)})
  def foldLeft[B](initial: B)(op: (B, (Time,A)) => B): B
}
