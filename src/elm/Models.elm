module Models exposing (..)

import Timeline.Models as TModel

type alias Model =
  { timeline: TModel.Model
  }

initialModel : Model
initialModel =
  { timeline = TModel.initialModel
  }
