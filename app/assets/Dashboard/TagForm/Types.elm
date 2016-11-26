module TagForm.Types exposing (..)

import Http
import Timeline.Types as Timeline

type Msg
  = TagSave Model
  | TagSaveFailure Http.Error

type alias Model =
  { title : String
  , description : String
  , category: String
  , timestamp: String
  , players: List String
  }
