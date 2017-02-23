module Types exposing (..)

import Controls.Types as Controls
import GameModel exposing (Game, GameLength, Timestamp)
import Http
import Minimap.Types as Minimap
import Navigation exposing (Location)
import TagCarousel.Types as TagCarousel
import Time


type Msg
  = TagCarouselMsg TagCarousel.Msg
  | ControlsMsg Controls.Msg
  | TimerUpdate Time.Time
  | MinimapMsg Minimap.Msg
  | SetGame (Result Http.Error Game)
  | LocationUpdate Location
  | SwitchView

type alias Model =
  { controls : Controls.Model
  , minimap : Minimap.Model
  , tagCarousel : TagCarousel.Model
  , game : Game
  , timestamp : Timestamp
  , viewType : ViewType
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

