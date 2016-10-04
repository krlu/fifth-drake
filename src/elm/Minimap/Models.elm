module Minimap.Models exposing (..)

type alias Model =
  { players : List Player
  }

type alias Player =
  { id: Int
  , x : Float
  , y : Float
  }

initialModel : Model
initialModel =
  { players = []
  }
