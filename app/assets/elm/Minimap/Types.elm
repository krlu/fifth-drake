module Minimap.Types exposing (..)

import Array exposing (..)
import Http

type Msg
  = SetData Game
  | PlayerFetchFailure Http.Error
  | UpdateTimestamp Int

type alias Model =
  { gameData : Game
  , timestamp : Int
  , background : String
  }

type alias Game =
  { blueTeam : Array Player
  , redTeam : Array Player
  }

type alias Player =
  { role: String
  , championName: String
  , ign: String
  , side: String
  , state: Array PlayerState
  }

type alias PlayerState =
  { position: Position
  , championState: ChampionState
  }

type alias Position =
  { x: Float
  , y: Float
  }

type alias ChampionState =
  { hp: Float
  , mp: Float
  , xp: Float
  }
