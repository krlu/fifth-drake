module TagCarousel.Types exposing (..)

import GameModel exposing (GameId, PlayerId, Timestamp)
import Http
import SettingsTypes exposing (GroupId, User, UserId)

type alias TagCategory = String
type alias TagId = String
type alias FirstName = String
type alias LastName = String
type alias Host = String
type alias ToShare = Bool

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
  | UpdateShare
  | ToggleShare TagId
  | ShareToggled (Result Http.Error ShareData)

type alias Model =
  { host             : Host
  , tags             : List Tag
  , tagForm          : TagForm
  , lastClickedTime  : Timestamp
  , tagButton        : String
  , deleteTagButton  : String
  }

type alias Tag =
  { id          : TagId
  , title       : String
  , description : String
  , category    : TagCategory
  , timestamp   : Timestamp
  , players     : List PlayerId
  , author      : User
  , authorizedGroups : List GroupId
  }

type alias TagForm =
  { title       : String
  , description : String
  , category    : TagCategory
  , selectedIds : List PlayerId
  , gameId      : GameId
  , host        : Host
  , active      : Bool
  , toShare     : ToShare
  }

type alias ShareData =
  { tagId : TagId
  , groupId : GroupId
  , isShared : Bool
  }
