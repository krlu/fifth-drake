module Types exposing (..)

import Controls.Types as Controls
import GameModel exposing (Game, GameLength, PlayerId, Timestamp)
import Http
import Minimap.Types as Minimap
import Navigation exposing (Location)
import TagCarousel.Types as TagCarousel
import PlayerDisplay.Types as PlayerDisplay
import Graph.Types as Graph
import Time


type Msg
  = TagCarouselMsg TagCarousel.Msg
  | ControlsMsg Controls.Msg
  | TimerUpdate Time.Time
  | MinimapMsg Minimap.Msg
  | SetGame (Result Http.Error Game)
  | LocationUpdate Location
  | SwitchView
  | PlayerDisplayMsg PlayerDisplay.Msg
  | GraphMsg Graph.Msg

type alias Model =
  { controls : Controls.Model
  , minimap : Minimap.Model
  , tagCarousel : TagCarousel.Model
  , game : Game
  , timestamp : Timestamp
  , viewType : ViewType
  , playerDisplay : PlayerDisplay.Model
  , graphStat : Graph.Model
  }

type alias Flags =
  { minimapBackground : String
  , playButton        : String
  , pauseButton       : String
  , addTagButton      : String
  , deleteTagButton   : String
  }

type ViewType = Map | Stats

type TimeSelection
  = Instant Timestamp
  | Range (Timestamp, Timestamp)

