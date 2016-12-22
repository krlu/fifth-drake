module TagCarousel.Types exposing (..)

import GameModel exposing (GameId, Timestamp)
import Http

type Msg
  = TagClick Timestamp
  | UpdateTags (Result Http.Error (List Tag))
  | DeleteTag String
  | TagDeleted (Result Http.Error String)
  | CreateTitle String
  | CreateDescription String
  | CreateCategory String
  | AddPlayers String
  | SwitchForm
  | SaveTag
  | TagSaved (Result Http.Error (List Tag))

type alias Model =
  { host    : String
  , tags    : List Tag
  , tagForm : TagForm
  }

type alias Tag =
  { id          : String
  , title       : String
  , description : String
  , category    : TagCategory
  , timestamp   : Timestamp
  , players     : List String
  }

type alias TagForm =
  { title       : String
  , description : String
  , category    : String
  , selectedIds : List String
  , gameId      : GameId
  , host        : String
  , active      : Bool
  }

type TagCategory
  = TeamFight
  | Objective
