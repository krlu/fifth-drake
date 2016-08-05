package gg.climb.lolobjects.game

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
	def inBase(): Boolean = {
		(x <= 5000 && y <= 5000) || (x >= 10000 && y >= 10000)
	}

	/**
		* Bot lane is defined in two segments:
		* 1) x: [5000, 15000], y: [0, 2500]
		* 2) x: [12500, 15000], y: [0, 10000]
		*
		* @return true if within bot lane boundaries, false otherwise
		*/
	def inBotLane(): Boolean = {
		(x >= 5000 && x <= 15000 && y >= 0 && y <= 2500) || (x >= 12500 && x <= 15000 && y >= 0 && y <= 10000)
	}
}

object LocationData {
	def apply(x: Double, y: Double, confidence: Double) = new LocationData(x,y,confidence)
}
