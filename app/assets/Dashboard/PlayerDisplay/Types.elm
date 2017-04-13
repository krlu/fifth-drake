module PlayerDisplay.Types exposing (..)

import GameModel exposing (PlayerId)
import Plot
import Set exposing (Set)

type Msg
  = PlotInteraction (Plot.Interaction Msg)
  | PlayerDisplayClicked PlayerId
  | PlayerDisplayHovered PlayerId
  | PlayerDisplayUnhovered

type alias Model =
  { selectedPlayers: Set PlayerId
  , hoveredPlayer : Maybe PlayerId
  }
