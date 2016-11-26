module TagForm.Types exposing (..)

import Http
import Timeline.Types as Timeline

type Msg
  = TagSave String
  | TagSaveFailure Http.Error

type alias Model =
  { title : String
  , description : String
  , category: String
  , timestamp: Timeline.Value
  , players: List String
  }
