module TagForm.Types exposing (..)

import Http exposing (RawError, Response)
import Timeline.Types as TimelineT
import TagScroller.Types exposing (Tag)
import TagForm.Internal.SaveTypes as Save

type Msg
 = CreateTitle String 
 | CreateDescription String
 | CreateCategory String 
 | AddPlayers String
 | CancelForm
 | SaveTag
 | SuccessOrFail Save.Msg

type alias Model =
  { title : String
  , description : String
  , category: String
  , players: String
  , gameId: String
  , host: String
  }
