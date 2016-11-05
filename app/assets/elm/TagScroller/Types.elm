module TagScroller.Types exposing (..)

import Http
import Timeline.Types as Timeline

type Msg
  = TagClick Timeline.Value
  | UpdateTags (List Tag)
  | TagFetchFailure Http.Error

type alias Model =
  { tags: List Tag
  }

type alias Tag =
  { title : String
  , description : String
  , category: TagCategory
  , timestamp: Timeline.Value
  , players: List String
  }

type TagCategory
  = TeamFight
  | Objective
