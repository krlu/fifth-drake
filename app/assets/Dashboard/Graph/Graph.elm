module Graph.Graph exposing (..)

import Array
import GameModel exposing (..)
import Graph.Types exposing (Model, Msg(ChangeStat), RangeForm, Stat(Gold, HP, XP))
import Set exposing (Set)
import Graph.Internal.View as View
import Html exposing (Html)
import Graph.Internal.Update as Update
import Plot


defaultRangeForm : RangeForm
defaultRangeForm =
  { start = 0
  , end = 0
  }

init :  Model
init =
  { selectedStat = XP
  , plotState = Plot.initialState
  , start = 0
  , end = 0
  , rangeForm = defaultRangeForm
  }

update : Msg -> Model -> GameLength -> (Model, Cmd Msg)
update = Update.update


view : Model -> Game -> Set PlayerId -> Html Msg
view = View.view
