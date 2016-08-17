package gg.climb.ramenx.core

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
}
