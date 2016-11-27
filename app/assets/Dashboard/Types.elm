module Types exposing (..)

import Array exposing (..)
import Dict exposing (Dict)
import Http
import Minimap.Types as Minimap
import Timeline.Types as Timeline
import TagScroller.Types as TagScroller

type Msg
  = TimelineMsg             Timeline.Msg
  | MinimapMsg              Minimap.Msg
  | TagScrollerMsg          TagScroller.Msg
  -- added the following three msg types
  | SetGameData             GameData
  | GameDataFetchFailure    Http.Error
  | UpdateTimestamp         Int

type alias Model =
  { timeline          : Timeline.Model
  , minimap           : Minimap.Model
  , tagScroller       : TagScroller.Model
  --added gameData
  , gameData          : GameData
  }

type alias WindowLocation =
  { host              : String
  , gameId            : String
  }

type alias Flags =
  { minimapBackground : String
  , playButton        : String
  , pauseButton       : String
  , location          : WindowLocation
  }

--added everything below this
type alias GameData =
  { blueTeam          : Team
  , redTeam           : Team
  }

type alias Team =
  { teamStates        : Array TeamState
  , playerStates      : Array Player
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
  , mp                : Float
  , xp                : Float
  , hpMax             : Float
  , mpMax             : Float
  , xpNextLevel       : Float
  }



type Role = Top | Jungle | Mid | Bot | Support
type Side = Red | Blue