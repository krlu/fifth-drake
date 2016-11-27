module TagForm.Types exposing (..)

import Http
import Timeline.Types as TimelineT
import TagScroller.Types exposing (Tag)

type Msg
 = CreateTitle String 
 | CreateDescription String
 | CreateCategory String 
 | CreateTimeStamp
 | AddPlayers String
 | CancelForm
 | SaveTag

type alias Model =
  { title : String
  , description : String
  , category: String
  , timestamp: TimelineT.Value
  , players: String
  }
