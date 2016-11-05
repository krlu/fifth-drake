module Types exposing (..)

import Minimap.Types as Minimap
import Timeline.Types as Timeline
import TagScroller.Types as TagScroller

type Msg
  = TimelineMsg Timeline.Msg
  | MinimapMsg Minimap.Msg
  | TagScrollerMsg TagScroller.Msg

type alias Flags =
  { minimapBackground: String
  , playButton: String
  , pauseButton: String
  }

type alias Model =
  { timeline: Timeline.Model
  , minimap: Minimap.Model
  , tagScroller: TagScroller.Model
  }
