module Types exposing (..)

import Dict exposing (Dict)
import Minimap.Types as Minimap
import Timeline.Types as Timeline
import TagScroller.Types as TagScroller
import TagForm.Types as TagForm

type Msg
  = TimelineMsg Timeline.Msg
  | MinimapMsg Minimap.Msg
  | TagScrollerMsg TagScroller.Msg
  | TagFormMsg TagForm.Msg

type alias Model =
  { timeline: Timeline.Model
  , minimap: Minimap.Model
  , tagScroller: TagScroller.Model
  }

type alias WindowLocation =
  { host: String
  , gameId: String
  }

type alias Flags =
  { minimapBackground: String
  , playButton: String
  , pauseButton: String
  , location: WindowLocation
  }

