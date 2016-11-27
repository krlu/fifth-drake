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
  -- the width and height of the map of the in game coordinates
  , mapWidth : Float
  , mapHeight : Float
  }

type alias Game =
  { blueTeam : Team
  , redTeam : Team
  }

type alias Team =
  { teamStates : Array TeamState
  , playerStates : Array Player
  }

type alias TeamState =
  { dragons : Int
  , barons : Int
  , turrets : Int
  }

type alias Player =
  { side: Side
  , role: Role
  , ign: String
  , championName: String
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



type Role = Top | Jungle | Mid | Bot | Support
type Side = Red | Blue

