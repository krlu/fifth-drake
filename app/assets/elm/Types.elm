module Types exposing (..)

import Dict exposing (Dict)
import Minimap.Types as Minimap
import Timeline.Types as Timeline
import TagScroller.Types as TagScroller

type Msg
  = TimelineMsg Timeline.Msg
  | MinimapMsg Minimap.Msg
  | TagScrollerMsg TagScroller.Msg

type alias Model =
  { timeline: Timeline.Model
  , minimap: Minimap.Model
  , tagScroller: TagScroller.Model
  }

type alias Location =
  { host: String
  , queryParams:
    { gameId: String
    }
  }

type alias Flags =
  { minimapBackground: String
  , playButton: String
  , pauseButton: String
  , location: Location
  }

