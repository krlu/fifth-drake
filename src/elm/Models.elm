module Models exposing (..)

import Timeline.Models as TModel
import Minimap.Models as MModel

type alias Model =
  { timeline: TModel.Model
  , minimap: MModel.Model
  }

initialModel : Model
initialModel =
  { timeline = TModel.initialModel
  , minimap = MModel.initialModel
  }
