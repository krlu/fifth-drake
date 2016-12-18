module TagCarousel.Types exposing (..)

import GameModel exposing (Timestamp)
import TagCarousel.Internal.DeleteTypes as Delete
import Http

type Msg
  = TagClick Timestamp
  | UpdateTags (Result Http.Error (List Tag))
  | DeleteTag String
  | SuccessOrFail Delete.Msg

type alias Model =
  { host : String
  , tags : List Tag
  }

type alias Tag =
  { id          : String
  , title       : String
  , description : String
  , category    : TagCategory
  , timestamp   : Timestamp
  , players     : List String
  }

type TagCategory
  = TeamFight
  | Objective

type alias Container a =
  { pages               : List a
  , pageWidth           : Int
  , currentPage         : Int
  , threshold           : Float
  , isDragging          : Bool
  , startDragPosition   : (Int, Int)
  , currentDragPosition : (Int, Int)
  }
