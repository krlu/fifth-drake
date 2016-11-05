package gg.climb.lolobjects.game

import gg.climb.Time
import gg.climb.lolobjects.esports.Player
import gg.climb.lolobjects.game.state.{PlayerState, Side, TeamState}
import gg.climb.ramenx.core.Behavior

/**
  * Encapsulates all in-game data for a given game
  */
class GameData(val teams: Side => InGameTeam)

class InGameTeam(val teamStates: Behavior[Time, TeamState],
                 val playerStates: Map[Player, Behavior[Time, PlayerState]])
