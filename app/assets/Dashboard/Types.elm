module Types exposing (..)

import GameModel exposing (Game, GameLength, Timestamp)
import Http
import Minimap.Types as Minimap
import Timeline.Types as Timeline
import TagScroller.Types as TagScroller
import TagForm.Types as TagForm

type Msg
  = TagScrollerMsg TagScroller.Msg
  | TimelineMsg Timeline.Msg
  | SetGame Game
  | GameDataFetchFailure Http.Error
  | UpdateTimestamp Timestamp
  | TagFormMsg TagForm.Msg


type alias Model =
  { timeline : Timeline.Model
  , minimap : Minimap.Model
  , tagScroller : TagScroller.Model
  , game : Game
  , timestamp : Timestamp
  , tagForm: TagForm.Model
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
