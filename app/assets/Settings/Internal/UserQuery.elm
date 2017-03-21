module Internal.UserQuery exposing (..)

import Http exposing (Request, emptyBody, expectJson, jsonBody, request)
import Json.Decode as Decoder exposing (Decoder, field, map4, string)
import Json.Encode exposing (Value, int, list, object)
import Navigation exposing (Location)
import SettingsTypes exposing (Msg(GetUser), User, UserForm)
import String

userUrl : String -> String
userUrl host = "http://" ++ host ++ "/a/getUser"

sendRequest: UserForm -> Location -> Cmd Msg
sendRequest userForm location = Http.send GetUser (requestUser userForm location)

requestUser: UserForm -> Location -> Request User
requestUser userForm location =
  let
    queryString ="?email=" ++ userForm.email
  in
    request
    {  method = "GET"
    , headers = []
    , url = (userUrl location.host) ++ queryString
    , body = emptyBody
    , expect = expectJson user
    , timeout = Nothing
    , withCredentials = False
    }

user : Decoder User
user =
  map4 User
    (field "id" string)
    (field "email" string)
    (field "firstName" string)
    (field "lastName" string)
