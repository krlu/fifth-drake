package gg.climb.fifthdrake.lolobjects.game

import gg.climb.fifthdrake.Time
import gg.climb.fifthdrake.lolobjects.esports.Player
import gg.climb.fifthdrake.lolobjects.game.state.{PlayerState, Side, TeamState}
import gg.climb.ramenx.Behavior

/**
  * Encapsulates all in-game data for a given game
  */
class GameData(val teams: Side => InGameTeam)

class InGameTeam(val teamStates: Behavior[Time, TeamState],
                 val playerStates: Map[Player, Behavior[Time, PlayerState]])
