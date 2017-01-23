module Minimap.Types exposing (..)

import Array exposing (..)
import Http

type alias Model =
  { background : String
  -- the width and height of the map of the in game coordinates
  , mapWidth : Float
  , mapHeight : Float
  }
