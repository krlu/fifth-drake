module Minimap.Models exposing (..)

import Array exposing (..)

type alias Model =
  { players : List Player
  , timestamp : Int
  }

type alias Player =
  { id: Int
  , state: Array PlayerState
  }

type alias PlayerState =
  { x: Float
  , y: Float
  }

initialModel : Model
initialModel =
  { players = []
  , timestamp = 0
  }
