module TagCarousel.Types exposing (..)

import GameModel exposing (GameId, PlayerId, Timestamp)
import Http
import SettingsTypes exposing (GroupId, User, UserId)

type alias TagCategory = String
type alias TagId = String
type alias FirstName = String
type alias LastName = String
type alias Host = String

type TagFilter = MyTags | GroupTags GroupId| AutoTags | AllTags

type Msg
  = TagClick (Timestamp, TagId)
  | UpdateTags (Result Http.Error (List Tag))
  | DeleteTag TagId
  | EditTag Tag
  | TagDeleted (Result Http.Error String)
  | CreateTitle String
  | CreateDescription String
  | CreateCategory String
  | AddPlayers PlayerId
  | SwitchForm
  | SaveTag
  | TagSaved (Result Http.Error (List Tag))
  | ToggleShare TagId
  | ShareToggled (Result Http.Error ShareData)
  | ToggleCarouselForm
  | ShowTagsForGroup GroupId
  | HighlightPlayers (List PlayerId)
  | UnhighlightPlayers
  | ShowAutoTags
  | ShowAllTags
  | ShowMyTags

type alias Model =
  { host               : Host
  , tags               : List Tag
  , tagForm            : TagForm
  , lastClickedTag     : TagId
  , highlightedPlayers : List PlayerId
  , tagButton          : String
  , deleteTagButton    : String
  , editTagButton      : String
  , isShareForm        : Bool
  , tagFilter          : TagFilter
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
  , tagId       : Maybe TagId
  }

type alias ShareData =
  { tagId : TagId
  , groupId : GroupId
  , isShared : Bool
  }
