module Minimap.Minimap exposing (init, view)

import Array
import GameModel exposing (..)
import Html exposing (Html)
import Minimap.Internal.View as View
import Minimap.Types exposing (..)
import Types exposing (WindowLocation)

initialModel : String -> Model
initialModel background =
  { background = background
  , mapWidth = 15000
  , mapHeight = 15000
  }

init : String -> Model
init = initialModel

view : Model -> GameData -> Timestamp -> Html a
view = View.view