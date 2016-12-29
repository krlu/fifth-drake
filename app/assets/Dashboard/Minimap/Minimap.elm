module Minimap.Minimap exposing (..)

import Array
import Dict exposing (Dict)
import GameModel exposing (..)
import Html exposing (Html)
import Minimap.Internal.View as View
import Minimap.Internal.Update as Update
import Minimap.Internal.Subscriptions as Subscriptions
import Minimap.Types exposing (..)

initialModel : String -> Model
initialModel background =
  { background = background
  , mapWidth = 15000
  , mapHeight = 15000
  , iconStates = Dict.empty
  }

init : String -> Model
init = initialModel

update : Model -> Data -> Timestamp -> Msg -> Model
update = Update.update

view : Model -> Html a
view = View.view

subscriptions : Model -> Sub Msg
subscriptions = Subscriptions.subscriptions
