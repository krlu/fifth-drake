module Types exposing (..)

import Controls.Types as Controls
import GameModel exposing (Game, GameLength, Timestamp)
import Http
import Minimap.Types as Minimap
import TagScroller.Types as TagScroller

type Msg
  = TagScrollerMsg TagScroller.Msg
  | ControlsMsg Controls.Msg
  | SetGame Game
  | GameDataFetchFailure Http.Error
  | UpdateTimestamp Timestamp

type alias Model =
  { controls : Controls.Model
  , minimap : Minimap.Model
  , tagScroller : TagScroller.Model
  , game : Game
  , timestamp : Timestamp
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
