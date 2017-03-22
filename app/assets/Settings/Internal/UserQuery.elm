module Internal.UserQuery exposing (sendRequestUser, populate)

import Http exposing (Request, emptyBody, expectJson, jsonBody, request)
import Json.Decode as Decoder exposing (Decoder, field, list, map2, map4, string)
import Json.Encode exposing (Value, int, object)
import Navigation exposing (Location)
import SettingsTypes exposing (Msg(GetGroupForUser, GetUser), User, UserForm, UserGroup)
import String

userUrl : String -> String
userUrl host = "http://" ++ host ++ "/a/getUser"

groupUrl : String -> String
groupUrl host = "http://" ++ host ++ "/a/getGroup"

sendRequestUser: UserForm -> Location -> Cmd Msg
sendRequestUser userForm location = Http.send GetUser (requestUser userForm location)

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

populate : Location -> Cmd Msg
populate loc = Http.send GetGroupForUser <| getGroup loc

getGroup : Location -> Http.Request UserGroup
getGroup loc = Http.get (groupUrl loc.host) group

group : Decoder UserGroup
group =
  map2 UserGroup
    (field "id" string)
    (field "users" <| list user)

user : Decoder User
user =
  map4 User
    (field "id" string)
    (field "email" string)
    (field "firstName" string)
    (field "lastName" string)
