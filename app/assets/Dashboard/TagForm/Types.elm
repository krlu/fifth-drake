module TagForm.Types exposing (..)

import GameModel exposing (GameId)
import Http
import TagCarousel.Types exposing (Msg(UpdateTags), Tag)

type Msg
 = CreateTitle String 
 | CreateDescription String
 | CreateCategory String 
 | AddPlayers String
 | CancelForm
 | SaveTag
 | TagSaved (Result Http.Error (List Tag))

type alias Model =
  { title : String
  , description : String
  , category: String
  , players: String
  , gameId: GameId
  , host: String
  }
