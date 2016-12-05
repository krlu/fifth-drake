module Types exposing (..)

import Controls.Types as Controls
import GameModel exposing (Game, GameLength, Timestamp)
import Http
import Minimap.Types as Minimap
import Navigation exposing (Location)
import TagScroller.Types as TagScroller

type Msg
  = TagScrollerMsg TagScroller.Msg
  | ControlsMsg Controls.Msg
  | SetGame (Result Http.Error Game)
  | UpdateTimestamp Timestamp
  | LocationUpdate Location

type alias Model =
  { controls : Controls.Model
  , minimap : Minimap.Model
  , tagScroller : TagScroller.Model
  , game : Game
  , timestamp : Timestamp
  }

type alias Flags =
  { minimapBackground : String
  , playButton        : String
  , pauseButton       : String
  }
