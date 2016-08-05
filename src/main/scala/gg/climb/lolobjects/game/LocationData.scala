package gg.climb.lolobjects.game

/**
 * Locational information for an object in a game of League.
 */
class LocationData(val x: Double, val y: Double, val confidence: Double)
object LocationData {
	def apply(x: Double, y: Double, confidence: Double) = new LocationData(x,y,confidence)
}
