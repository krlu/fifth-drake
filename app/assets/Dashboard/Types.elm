module Types exposing (..)

import Controls.Types as Controls
import GameModel exposing (Game, GameLength, Timestamp)
import Http
import Minimap.Types as Minimap
import TagCarousel.Types as TagCarousel
import Navigation exposing (Location)
import PlayerDisplay.Types as PlayerDisplay


type Msg
  = TagCarouselMsg TagCarousel.Msg
  | ControlsMsg Controls.Msg
  | SetGame (Result Http.Error Game)
  | LocationUpdate Location
  | PlayerDisplayMsg  PlayerDisplay.Msg

type TimeSelection
  = Instant Timestamp
  | Range (Timestamp, Timestamp)

type alias Model =
  { controls : Controls.Model
  , minimap : Minimap.Model
  , tagCarousel : TagCarousel.Model
  , game : Game
  , tagCarousel: TagCarousel.Model
  , selection : TimeSelection
  , timestamp : Timestamp
  }

type alias Flags =
  { minimapBackground : String
  , playButton        : String
  , pauseButton       : String
  , addTagButton      : String
  , deleteTagButton   : String
  }
