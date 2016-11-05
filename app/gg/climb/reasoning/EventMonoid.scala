package gg.climb.reasoning

import java.util.concurrent.TimeUnit

import scala.concurrent.duration.Duration
import scalaz.Monoid

object EventMonoid extends Monoid[Duration] {
  override def zero: Duration = Duration(0, TimeUnit.MILLISECONDS)
  override def append(f1: Duration, f2: => Duration): Duration = f1 + f2
}
