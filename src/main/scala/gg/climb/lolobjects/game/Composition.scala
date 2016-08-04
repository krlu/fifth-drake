package gg.climb.lolobjects.game

/**
 * Represents a team composition that can be used for each side of the map.
 */
class Composition(top: Champion, jungle: Champion, mid: Champion, bot: Champion, support: Champion) {
  def list = List(top, jungle, mid, bot, support)
}
