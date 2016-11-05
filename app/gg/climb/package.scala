package gg

import gg.climb.lolobjects.game.{GameData, MetaData}

import scala.concurrent.duration.Duration
import scalaz.Monoid

/**
  * Created by prasanth on 11/5/16.
  */
package object climb {
  type Time = Duration
  type Game = (MetaData, GameData)

  implicit object TimeMonoid extends Monoid[Time] {
    override def zero: Time = Duration.Zero
    override def append(f1: Time, f2: => Time): Time = f1 + f2
  }
}
