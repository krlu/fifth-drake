module Graph.Types exposing (..)

import GameModel exposing (PlayerId, Timestamp)
import Plot
import Set exposing (Set)

type Msg = ChangeStat String  | PlotInteraction (Plot.Interaction Msg)

type alias Color = String

type Stat = Gold | XP | HP

type alias Model =
  { selectedStat: Stat
  , plotState : Plot.State
  , start : Timestamp
  , end : Timestamp
  }
