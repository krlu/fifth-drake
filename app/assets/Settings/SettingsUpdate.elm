module SettingsUpdate exposing (update)

import Internal.UserQuery exposing (..)
import SettingsTypes exposing (..)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    LocationUpdate loc -> (model, Cmd.none)
    UpdateSearchForm email ->
     let
        oldForm = model.form
        newForm = { oldForm | email = email}
     in
      ( {model | form = newForm }, Cmd.none)
    SendGetUserRequest -> ( model, sendGetUserRequest model.form model.location)
    GetUser(Ok user) ->
      case model.group of
        Nothing -> (model, Cmd.none)
        Just group -> (model, sendAddUserRequest user group model.location)
    GetUser (Err err) -> (Debug.log "User failed to fetch!" model, Cmd.none)
    GetDataForUser (Ok data) ->
      ({ model | group = Just data.group
      , permissions = Just data.permissions 
      , currentUser = Just data.currentUser}, Cmd.none)
    GetDataForUser (Err err) ->
      (Debug.log "Group failed to fetch!" model, Cmd.none)
    RemoveUser user ->
      case model.group of
        Nothing -> (model, Cmd.none)
        Just group -> (model, sendRemoveUserRequest user group model.location)
    SendRemoveUserRequest (Ok group) -> ({ model | group = Just group} , Cmd.none)
    SendRemoveUserRequest (Err err) -> (Debug.log "Failed to remove user from group!" model, Cmd.none)
    SendCreateGroupRequest -> (model, sendCreateGroupRequest model.location)
    UpdatePermission (userId, groupId, level) ->
      (model, sendUpdatePermissionRequest userId groupId level model.location)
    SendPermissionsRequest (Ok permissions) -> ({ model | permissions = Just permissions} , Cmd.none)
    SendPermissionsRequest (Err err) -> (Debug.log "Failed to add user to group!" model, Cmd.none)
    DeleteGroup groupId ->
     (model, sendDeleteGroupRequest groupId model.location)
    SendDeleteGroupRequest (Ok msg) -> (Debug.log msg { model | group = Nothing, permissions = Nothing} , Cmd.none)
    SendDeleteGroupRequest (Err err) -> (Debug.log "Failed to delete group!" model, Cmd.none)
