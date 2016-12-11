module TagForm.Types exposing (..)

import GameModel exposing (GameId)
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
  , gameId: GameId
  , host: String
  }
