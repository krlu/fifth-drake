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
    GetGroupForUser (Ok group) ->
      ({ model | group = Just group }, Cmd.none)
    GetGroupForUser (Err err) ->
      (Debug.log "Group failed to fetch!" model, Cmd.none)
    SendAddUserRequest (Ok group) -> ({ model | group = Debug.log "" (Just group)} , Cmd.none)
    SendAddUserRequest (Err err) -> (Debug.log "Failed to add user to group!" model, Cmd.none)
    RemoveUser user ->
      case model.group of
        Nothing -> (model, Cmd.none)
        Just group -> (model, sendRemoveUserRequest user group model.location)
    SendRemoveUserRequest (Ok group) -> ({ model | group = Just group} , Cmd.none)
    SendRemoveUserRequest (Err err) -> (Debug.log "Failed to remove user from group!" model, Cmd.none)
    SendCreateGroupRequest -> (model, sendCreateGroupRequest model.location)
