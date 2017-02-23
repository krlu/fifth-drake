module Graph.Types exposing (..)

import GameModel exposing (PlayerId)
import Plot
import Set exposing (Set)

type Msg = ChangeStat String

type Stat = Gold | XP

type alias Model =
  { selectedStat: Stat
  }
