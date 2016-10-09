package gg.climb.lolobjects.game

import gg.climb.lolobjects.esports._

/**
 * Represents a team composition that can be used for each side of the map.
 */
class Composition(top: Champion,
                  jungle: Champion,
                  mid: Champion,
                  bot: Champion,
                  support: Champion) extends Traversable[(Role, Champion)] {

  val map: Map[Role, Champion] = Map(
    Top -> top,
    Jungle -> jungle,
    Mid -> mid,
    Bot -> bot,
    Support -> support
  )

  override def foreach[U](f: ((Role, Champion)) => U): Unit = map.foreach(f)
}
