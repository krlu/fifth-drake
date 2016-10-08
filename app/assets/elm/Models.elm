module Models exposing (..)

import Minimap.Models as MModel
import Timeline.Models as TModel

type alias Flags =
  { minimapBackground: String
  , playButton: String
  , pauseButton: String
  }

type alias Model =
  { timeline: TModel.Model
  , minimap: MModel.Model
  }

initialModel : Flags -> Model
initialModel flags =
  { timeline = TModel.initialModel flags
  , minimap = MModel.initialModel flags.minimapBackground
  }
