package gg.climb.lolobjects.game.state

/**
  * Locational information for an object in a game of League.
  */
class LocationData(val x: Double, val y: Double, val confidence: Double) {

  /**
    * Assuming length of one side of SR is 15,000 units
    * and length of one side of the base is 5,000 units
    *
    * @return true if within base boundaries, false otherwise
    */
  def inBase: Boolean = {
    (x <= 5000 && y <= 5000) || (x >= 10000 && y >= 10000)
  }

  /**
    * In any of bot, mid or top lane
    *
    * @return true if in lane, false otherwise
    */
  def inLane: Boolean = {
    inBotLane && inMidLane && inTopLane
  }

  /**
    * Bot lane is defined in two segments:
    * 1) x: [5000, 15000], y: [0, 1000]
    * 2) x: [14000, 15000], y: [0, 10000]
    *
    * @return true if within bot lane boundaries, false otherwise
    */
  def inBotLane: Boolean = {
    (x >= 5000 && x <= 15000 && y >= 0 && y <= 1000) ||
      (x >= 14000 && x <= 15000 && y >= 0 && y <= 10000)
  }

  /**
    * Mid lane is defined in one segment using the following functions:
    *
    * 1) y >= x - 700 where x: [5000, 11300]
    * 2) y <= x + 700 where x: [4300, 10000]
    *
    * @return true if within mid lane boundaries, false otherwise
    */
  def inMidLane: Boolean = {
    (y >= x - 700 && x >= 5000 && x <= 11300) && (y <= x + 700 && x >= 4300 && x <= 10000)
  }

  /**
    * Top lane is defined in two segments:
    * 1) x: [0, 1000], y: [5000, 15000]
    * 2) x: [0, 10000], y: [14000, 15000]
    *
    * @return true if within top lane boundariers, false otherwise
    */
  def inTopLane: Boolean = {
    (x >= 0 && x <= 1000 && y >= 5000 && y <= 15000) ||
      (x >= 0 && x <= 10000 && y >= 14000 && y <= 15000)
  }

  override def toString : String = s"LocationData($x, $y)"
}
