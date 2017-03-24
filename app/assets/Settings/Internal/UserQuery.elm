module Internal.UserQuery exposing (sendGetUserRequest, populate, sendAddUserRequest, sendRemoveUserRequest)

import Http exposing (Request, emptyBody, expectJson, jsonBody, request)
import Json.Decode as Decoder exposing (Decoder, field, list, map2, map4, string)
import Json.Encode exposing (Value, int, object)
import Navigation exposing (Location)
import SettingsTypes exposing (..)
import String

userUrl : String -> String
userUrl host = "http://" ++ host ++ "/a/getUser"

groupUrl : String -> String
groupUrl host = "http://" ++ host ++ "/a/getGroup"

addUserUrl : String -> String
addUserUrl host = "http://" ++ host ++ "/a/addUserToGroup"

removeUserUrl : String -> String
removeUserUrl host = "http://" ++ host ++ "/a/removeUserFromGroup"

sendRemoveUserRequest : User -> UserGroup -> Location -> Cmd Msg
sendRemoveUserRequest user group location = Http.send SendRemoveUserRequest (removeUser user.id group.id location)

removeUser: UserId -> GroupId -> Location -> Request UserGroup
removeUser userId groupId location =
  let
    queryString =  (removeUserUrl location.host) ++ "?user=" ++ userId ++ ";group=" ++ groupId
  in
    request
     {  method = "DELETE"
      , headers = []
      , url = Debug.log "" queryString
      , body = emptyBody
      , expect = expectJson group
      , timeout = Nothing
      , withCredentials = False
     }

sendAddUserRequest : User -> UserGroup -> Location -> Cmd Msg
sendAddUserRequest user group location = Http.send SendAddUserRequest (addUser user.id group.id location)

addUser: UserId -> GroupId -> Location -> Request UserGroup
addUser userId groupId location =
  let
    queryString =  (addUserUrl location.host) ++ "?user=" ++ userId ++ ";group=" ++ groupId
  in
    request
     {  method = "PUT"
      , headers = []
      , url = queryString
      , body = emptyBody
      , expect = expectJson group
      , timeout = Nothing
      , withCredentials = False
     }

sendGetUserRequest: UserForm -> Location -> Cmd Msg
sendGetUserRequest userForm location = Http.send GetUser (getUser userForm location)

getUser: UserForm -> Location -> Request User
getUser userForm location =
  let
    queryString = (userUrl location.host) ++ "?email=" ++ userForm.email
  in
    Http.get queryString user

populate : Location -> Cmd Msg
populate loc = Http.send GetGroupForUser <| getGroup loc

getGroup : Location -> Request UserGroup
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
