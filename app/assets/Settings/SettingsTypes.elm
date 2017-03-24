module SettingsTypes exposing (..)

import Http
import Navigation exposing (Location)

type Msg
  = SendGetUserRequest
  | GetUser (Result Http.Error User)
  | LocationUpdate Location
  | UpdateSearchForm String
  | GetGroupForUser (Result Http.Error UserGroup)
  | AddUserToGroup User
  | SendAddUserRequest (Result Http.Error UserGroup)
  | RemoveUser User
  | SendRemoveUserRequest (Result Http.Error UserGroup)

type alias Email = String
type alias UserId = String
type alias GroupId = String

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

type alias Model =
  { group : Maybe UserGroup
  , form : UserForm
  , location : Location
  , foundUser : Maybe User
  , searchIcon : String
  , addUserIcon : String
  }

type alias Flags =
  { searchIcon : String
  , addUserIcon : String
  }
