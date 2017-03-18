package gg.climb

import gg.climb.fifthdrake.lolobjects.game.{GameData, MetaData}
import gg.climb.fifthdrake.reasoning.GameEvent

import scala.concurrent.duration.Duration
import scalaz.Monoid

/**
  * Created by prasanth on 11/5/16.
  */
package object fifthdrake {
  type Time = Duration
  type Game = (MetaData, GameData)
  type GoogleClientId = String
  type GoogleClientSecret = String
  type Timeline = Seq[GameEvent]

  implicit object TimeMonoid extends Monoid[Time] {
    override def zero: Time = Duration.Zero
    override def append(f1: Time, f2: => Time): Time = f1 + f2
  }
}
