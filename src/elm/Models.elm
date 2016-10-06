module Models exposing (..)

import Minimap.Models as MModel
import Timeline.Models as TModel

type alias Model =
  { timeline: TModel.Model
  , minimap: MModel.Model
  }

initialModel : Model
initialModel =
  { timeline = TModel.initialModel
  , minimap = MModel.initialModel
  }
