module TagForm.Types exposing (..)

import Http
import Timeline.Types as Timeline

type Msg
 = CreateTitle String 
 | CreateDescription String
 | CreateCategory String 
 | CreateTimeStamp String
 | AddPlayers String
 | CancelForm
