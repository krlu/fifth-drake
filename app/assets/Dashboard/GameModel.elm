module GameModel exposing (..)

import Array exposing (Array)

type alias GameId = Int

type alias GameLength = Timestamp
type alias Timestamp = Int

type alias Game =
  { metadata : Metadata
  , data : Data
  }

{-| This represents all metadata in a game.
gameLength is the total duration of the game in seconds.
-}
type alias Metadata =
  { blueTeamName       : String
  , redTeamName        : String
  , gameLength         : GameLength
  }

type alias Data =
  { blueTeam          : Team
  , redTeam           : Team
  }

type alias Team =
  { teamStates        : Array TeamState
  , players           : Array Player
  }

type alias TeamState =
  { dragons           : Int
  , barons            : Int
  , turrets           : Int
  }

type alias Player =
  { side              : Side
  , role              : Role
  , ign               : String
  , championName      : String
  , championImage     : String
  , state             : Array PlayerState
  }

type alias PlayerState =
  { position          : Position
  , championState     : ChampionState
  }

type alias Position =
  { x                 : Float
  , y                 : Float
  }

type alias ChampionState =
  { hp                : Float
  , hpMax             : Float
  , power             : Float
  , powerMax          : Float
  , xp                : Float
  }

type Role = Top | Jungle | Mid | Bot | Support
type Side = Red | Blue
