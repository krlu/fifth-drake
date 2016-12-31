module Types exposing (..)

import Controls.Types as Controls
import GameModel exposing (Game, GameLength, Timestamp)
import Http
import Minimap.Types as Minimap
import TagCarousel.Types as TagCarousel
import Navigation exposing (Location)


type Msg
  = TagCarouselMsg TagCarousel.Msg
  | ControlsMsg Controls.Msg
  | MinimapMsg Minimap.Msg
  | SetGame (Result Http.Error Game)
  | LocationUpdate Location

type alias Model =
  { controls : Controls.Model
  , minimap : Minimap.Model
  , tagCarousel : TagCarousel.Model
  , game : Game
  , timestamp : Timestamp
  , tagCarousel: TagCarousel.Model
  }

type alias Flags =
  { minimapBackground : String
  , playButton        : String
  , pauseButton       : String
  }
