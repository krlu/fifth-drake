module SettingsTypes exposing (..)

import Http
import Navigation exposing (Location)

type Msg
  = SendGetUserRequest
  | GetUser (Result Http.Error User)
  | LocationUpdate Location
  | UpdateSearchForm String

type alias Email = String
type alias UserId = String

type alias UserForm =
  { email : Email
  }

type alias User =
  { id : UserId
  , email : Email
  , firstName : String
  , lastName : String
  }

type alias Model =
  { users : List User
  , form : UserForm
  , location : Location
  , foundUser : Maybe User
  }

type alias Flags =
  {
  }
