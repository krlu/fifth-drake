package gg.climb.fifthdrake.lolobjects.game.state

/**
  * Locational information for an object in a game of League.
  */
class LocationData(val x: Double, val y: Double, val confidence: Double) {
  override def toString : String = s"LocationData($x, $y)"
}

sealed  trait LocationType
case object InLane extends LocationType
case object InJungle extends LocationType
case object InBase extends LocationType
