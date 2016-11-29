module Types exposing (..)

import GameModel exposing (GameData, GameLength, Timestamp)
import Http
import Minimap.Types as Minimap
import Timeline.Types as Timeline
import TagScroller.Types as TagScroller

type Msg
  = TagScrollerMsg TagScroller.Msg
  | TimelineMsg Timeline.Msg
  | SetGameData GameData
  | GameDataFetchFailure Http.Error
  | UpdateTimestamp Timestamp

type alias Model =
  { timeline          : Timeline.Model
  , minimap           : Minimap.Model
  , tagScroller       : TagScroller.Model
  --added gameData
  , gameData          : GameData
  , timestamp         : Timestamp
  , gameLength        : GameLength
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