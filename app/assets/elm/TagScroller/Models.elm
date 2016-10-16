module TagScroller.Models exposing (..)

type alias Model =
  { tags: List Tag
  }

type alias Tag =
  { tagType: TagType
  , timestamp: Int
  }

type TagType
  = TeamFight
  | UserDefined

initialModel : Model
initialModel =
  { tags = []
  }
