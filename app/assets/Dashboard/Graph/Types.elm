module Graph.Types exposing (..)

import GameModel exposing (PlayerId)
import Plot
import Set exposing (Set)

type Msg = ChangeStat String  | PlotInteraction (Plot.Interaction Msg)

type Stat = Gold | XP | HP

type alias Model =
  { selectedStat: Stat
  , plotState : Plot.State
  }
