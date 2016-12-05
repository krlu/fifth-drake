module TagScroller.Types exposing (..)

import GameModel exposing (Timestamp)
import Http

type Msg
  = TagClick Timestamp
  | UpdateTags (Result Http.Error (List Tag))

type alias Model =
  { tags: List Tag
  }

type alias Tag =
  { title : String
  , description : String
  , category: TagCategory
  , timestamp: Timestamp
  , players: List String
  }

type TagCategory
  = TeamFight
  | Objective
