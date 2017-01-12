module Minimap.Types exposing (..)

import Animation
import Array exposing (..)
import Dict exposing (Dict)
import GameModel exposing (PlayerId, Side)

type alias Model =
  { background : String
  -- the width and height of the map of the in game coordinates
  , mapWidth : Float
  , mapHeight : Float
  , iconStates : Dict PlayerId State
  }

type Msg
  = AnimatePlayerIcons Animation.Msg
  | GenerateIconStates
  | MoveIconStates Action

type alias State =
  { style : Animation.State
  , side : Side
  , img : String
  }

type Action = Snap | Increment
--type Snap = String
--type Increment = String