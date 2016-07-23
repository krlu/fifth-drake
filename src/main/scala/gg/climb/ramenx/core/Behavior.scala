package gg.climb.ramenx.core

/**
  * Created by prasanth on 7/20/16.
  */
trait Behavior[time <: Ordered[time], +A] {
  def get(t : time) : A
}
