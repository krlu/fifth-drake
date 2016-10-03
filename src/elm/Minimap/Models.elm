module Minimap.Models exposing (..)

type alias Model =
  { players : List Player
  }

type alias Player =
  { x : Int
  , y : Int
  }

initialModel : Model
initialModel =
  { players = []
  }
