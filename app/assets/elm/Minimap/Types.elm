module Minimap.Types exposing (..)

import Array exposing (..)
import Http

type Msg
  = SetPlayers (List Player)
  | PlayerFetchFailure Http.Error
  | UpdateTimestamp Int

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
