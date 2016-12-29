module Minimap.Types exposing (..)

import Animation
import Array exposing (..)
import Dict exposing (Dict)
import GameModel exposing (Side)

type alias Model =
  { background : String
  -- the width and height of the map of the in game coordinates
  , mapWidth : Float
  , mapHeight : Float
  , iconStates : Dict String State
  }

type Msg =
  AnimatePlayerIcon Animation.Msg

type alias State =
  { style : Animation.State
  , side : Side
  , img : String
  }