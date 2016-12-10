module Types exposing (..)

import Controls.Types as Controls
import GameModel exposing (Game, GameLength, Timestamp)
import Http
import Minimap.Types as Minimap
import TagCarousel.Types as TagCarousel
import TagForm.Types as TagForm

type Msg
  = TagCarouselMsg TagCarousel.Msg
  | ControlsMsg Controls.Msg
  | SetGame Game
  | GameDataFetchFailure Http.Error
  | UpdateTimestamp Timestamp
  | TagFormMsg TagForm.Msg


type alias Model =
  { controls : Controls.Model
  , minimap : Minimap.Model
  , tagCarousel : TagCarousel.Model
  , game : Game
  , timestamp : Timestamp
  , tagForm: TagForm.Model
  , tagCarousel: TagCarousel.Model
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
