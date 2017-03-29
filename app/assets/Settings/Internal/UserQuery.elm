module Internal.UserQuery exposing
  ( sendGetUserRequest
  , populate
  , sendAddUserRequest
  , sendRemoveUserRequest
  , sendCreateGroupRequest
  , sendUpdatePermissionRequest
  , sendDeleteGroupRequest
  )

import Http exposing (Request, emptyBody, expectJson, expectString, jsonBody, request)
import Json.Decode as Decoder exposing (Decoder, field, list, map2, map3, map4, string)
import Json.Encode exposing (Value, int, object)
import Navigation exposing (Location)
import SettingsTypes exposing (..)
import String


-- URLS for data sources

userUrl : String -> String
userUrl host = "http://" ++ host ++ "/a/getUser"

groupUrl : String -> String
groupUrl host = "http://" ++ host ++ "/a/getSettingsData"

createGroupUrl : String -> String
createGroupUrl host = "http://" ++ host ++ "/a/createGroup"

addUserUrl : String -> String
addUserUrl host = "http://" ++ host ++ "/a/addUserToGroup"

updatePermissionUrl : String -> String
updatePermissionUrl host = "http://" ++ host ++ "/a/updateUserPermission"

removeUserUrl : String -> String
removeUserUrl host = "http://" ++ host ++ "/a/removeUserFromGroup"

deleteGroupUrl : String -> String
deleteGroupUrl host = "http://" ++ host ++ "/a/deleteGroup"

-- Request senders and formatters


sendCreateGroupRequest : Location -> Cmd Msg
sendCreateGroupRequest location = Http.send GetDataForUser <| buildRequest "GET" (createGroupUrl location.host) data

sendDeleteGroupRequest: GroupId -> Location -> Cmd Msg
sendDeleteGroupRequest groupId location = Http.send SendDeleteGroupRequest <| deleteGroup groupId location

deleteGroup: GroupId -> Location -> Request GroupId
deleteGroup groupId location=
  let
    queryString = (deleteGroupUrl location.host) ++ "?id=" ++ groupId
  in
  request
   {  method = "DELETE"
    , headers = []
    , url = queryString
    , body = emptyBody
    , expect = expectString
    , timeout = Nothing
    , withCredentials = False
   }

sendUpdatePermissionRequest : UserId -> GroupId-> PermissionLevel -> Location -> Cmd Msg
sendUpdatePermissionRequest userId groupId permissionLevel location =
  Http.send SendPermissionsRequest (updatePermission userId groupId permissionLevel location)

updatePermission : UserId -> GroupId -> PermissionLevel -> Location -> Request (List Permission)
updatePermission userId groupId permissionLevel location =
  let
    queryString =
      (updatePermissionUrl location.host)
      ++ "?user=" ++ userId
      ++ ";group=" ++ groupId
      ++ ";level=" ++ permissionLevel
  in
    buildRequest "PUT" queryString (list permission)

sendRemoveUserRequest : User -> UserGroup -> Location -> Cmd Msg
sendRemoveUserRequest user group location =
  Http.send SendRemoveUserRequest (removeUser user.id group.id location)

removeUser : UserId -> GroupId -> Location -> Request UserGroup
removeUser userId groupId location =
  let
    queryString =
      (removeUserUrl location.host)
       ++ "?user=" ++ userId
       ++ ";group=" ++ groupId
  in
    buildRequest "DELETE" queryString group

sendAddUserRequest : User -> UserGroup -> Location -> Cmd Msg
sendAddUserRequest user group location =
  Http.send GetDataForUser (addUser user.id group.id location)

addUser: UserId -> GroupId -> Location -> Request Data
addUser userId groupId location =
  let
    queryString =
      (addUserUrl location.host)
       ++ "?user=" ++ userId
       ++ ";group=" ++ groupId
  in
    buildRequest "PUT" queryString data

buildRequest : String -> String -> (Decoder a) -> Request a
buildRequest method queryString decoder =
  request
   {  method = method
    , headers = []
    , url = queryString
    , body = emptyBody
    , expect = expectJson decoder
    , timeout = Nothing
    , withCredentials = False
   }

sendGetUserRequest: UserForm -> Location -> Cmd Msg
sendGetUserRequest userForm location =
  Http.send GetUser (getUser userForm location)

getUser: UserForm -> Location -> Request User
getUser userForm location =
  Http.get ((userUrl location.host) ++ "?email=" ++ userForm.email) user


-- Data Encoding/Decoding

populate : Location -> Cmd Msg
populate loc = Http.send GetDataForUser <| getGroup loc

getGroup : Location -> Request Data
getGroup loc = Http.get (groupUrl loc.host) data

data : Decoder Data
data =
  map3 SettingsTypes.Data
    (field "group" group)
    (field "permissions" <| list permission)
    (field "currentUser" user)

permission : Decoder Permission
permission =
  map2 Permission
    (field "userId" string)
    (field "level" string)

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
