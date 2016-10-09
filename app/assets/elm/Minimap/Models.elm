module Minimap.Models exposing (..)

import Array exposing (..)

type alias Model =
  { players : List Player
  , timestamp : Int
  , background : String
  }

type alias Player =
  { id: Int
  , state: Array PlayerState
  }

type alias PlayerState =
  { x: Float
  , y: Float
  }

initialModel : String -> Model
initialModel background =
  { players = []
  , timestamp = 0
  , background = background
  }
