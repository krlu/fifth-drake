package gg.climb.ramenx.core

trait Behavior[Time, +A] {
  def get(t : Time) : A
  def map[B](f: A => B): Behavior[Time, B]
}
