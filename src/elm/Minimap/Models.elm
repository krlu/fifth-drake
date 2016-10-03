module Minimap.Models exposing (..)

type alias Model =
  { players : List Player
  }

type alias Player =
  { x : Float
  , y : Float
  }

initialModel : Model
initialModel =
  { players = []
  }
