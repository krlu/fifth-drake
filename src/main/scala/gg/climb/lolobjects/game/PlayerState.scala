package gg.climb.lolobjects.game

import gg.climb.lolobjects.esports.Player

/**
 * A human player represented in League.
 */
class PlayerState(player: Player,
                  champion: String,
                  timestamp: Long,
                  hp: Double,
                  mp: Double,
                  xp: Double,
                  location: LocationData)
