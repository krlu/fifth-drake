module SettingsTypes exposing (..)

import Http
import Navigation exposing (Location)

type alias Email = String
type alias UserId = String
type alias GroupId = String
type alias Icon = String
type alias PermissionLevel = String


type Msg
  = SendGetUserRequest
  | GetUser (Result Http.Error User)
  | LocationUpdate Location
  | UpdateSearchForm String
  | GetGroupForUser (Result Http.Error UserGroup)
  | RemoveUser User
  | SendRemoveUserRequest (Result Http.Error UserGroup)
  | SendCreateGroupRequest
  | GetDataForUser (Result Http.Error Data)
  | UpdatePermission (UserId, GroupId, PermissionLevel)
  | SendPermissionsRequest (Result Http.Error (List Permission))

type alias UserForm =
  { email : Email
  }

type alias User =
  { id : UserId
  , email : Email
  , firstName : String
  , lastName : String
  }

type alias UserGroup =
  { id : GroupId
  , members : List User
  }

type alias Permission =
  { userId : UserId
  , level : PermissionLevel
  }

type alias Data =
  { group : UserGroup
  , permissions : List Permission
  , currentUser : User
  }

type alias Model =
  { group : Maybe UserGroup
  , permissions : Maybe (List Permission)
  , currentUser : Maybe User
  , form : UserForm
  , location : Location
  , searchIcon : Icon
  , addUserIcon : Icon
  , removeUserIcon : Icon
  , updatePermissionIcon : Icon
  }

type alias Flags =
  { searchIcon : Icon
  , addUserIcon : Icon
  , removeUserIcon : Icon
  , updatePermissionIcon : Icon
  }
