module TagCarousel.Types exposing (..)

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

type alias Container a =
  { pages       : List a
  , pageWidth   : Int
  , currentPage : Int
  , threshold   : Float
  , isDragging  : Bool
  , startDragPosition : (Int, Int)
  , currentDragPosition : (Int, Int)
  }
