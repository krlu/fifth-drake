module TagCarousel.Types exposing (..)

import GameModel exposing (GameId, PlayerId, Timestamp)
import Http


type alias TagId = String

type Msg
  = TagClick Timestamp
  | UpdateTags (Result Http.Error (List Tag))
  | DeleteTag TagId
  | TagDeleted (Result Http.Error String)
  | CreateTitle String
  | CreateDescription String
  | CreateCategory String
  | AddPlayers PlayerId
  | SwitchForm
  | SaveTag
  | TagSaved (Result Http.Error (List Tag))
  | MouseOverTag TagId
  | MouseLeaveTag
  | MouseOverForm
  | MouseLeaveForm

type alias Model =
  { host             : String
  , tags             : List Tag
  , tagForm          : TagForm
  , lastClickedTime  : Timestamp
  , tagButton        : String
  , hoveredTag       : Maybe TagId
  }

type alias Tag =
  { id          : TagId
  , title       : String
  , description : String
  , category    : TagCategory
  , timestamp   : Timestamp
  , players     : List PlayerId
  }

type alias TagForm =
  { title       : String
  , description : String
  , category    : String
  , selectedIds : List PlayerId
  , gameId      : GameId
  , host        : String
  , active      : Bool
  , hovered     : Bool
  }

type TagCategory
  = TeamFight
  | Objective
