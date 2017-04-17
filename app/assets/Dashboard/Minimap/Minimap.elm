module Minimap.Minimap exposing (..)

import Array
import Dict exposing (Dict)
import GameModel exposing (..)
import Html exposing (Html)
import Minimap.Internal.Update as Update
import Minimap.Internal.View as View
import Minimap.Internal.Subscriptions as Subscriptions
import Minimap.Types exposing (..)
import Set exposing (Set)
import SettingsTypes exposing (Icon)
import Types exposing (Flags, ObjectiveEvent)

initialModel : Flags -> Model
initialModel flags =
  { background = flags.minimapBackground
  , mapWidth = 15000
  , mapHeight = 15000
  , iconStates = Dict.empty
  , blueTowerIcon = flags.blueTowerIcon
  , redTowerIcon = flags.redTowerIcon
  , blueTowerKillIcon = flags.blueTowerKillIcon
  , redTowerKillIcon = flags.redTowerKillIcon
  , blueInhibitorIcon = flags.blueInhibitorIcon
  , redInhibitorIcon = flags.redInhibitorIcon
  , blueInhibitorKillIcon = flags.blueInhibitorKillIcon
  , redInhibitorKillIcon = flags.redInhibitorKillIcon
  }

init : Flags -> Model
init = initialModel

update : Model -> Data -> Timestamp -> Msg -> Model
update = Update.update

view : Types.Model -> Html a
view = View.view

subscriptions : Model -> Sub Msg
subscriptions = Subscriptions.subscriptions
