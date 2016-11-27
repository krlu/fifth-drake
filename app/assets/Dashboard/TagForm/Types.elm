module TagForm.Types exposing (..)

import Http
import Timeline.Types as Timeline
import TagScroller.Types exposing (Tag)

type Msg
 = CreateTitle String 
 | CreateDescription String
 | CreateCategory String 
 | CreateTimeStamp String
 | AddPlayers String
 | CancelForm
 | SaveTag

type alias Model =
  { title : String
  , description : String
  , category: String
  , timestamp: String
  , players: String
  }
