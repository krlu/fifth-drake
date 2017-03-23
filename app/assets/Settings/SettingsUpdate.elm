module SettingsUpdate exposing (update)

import Internal.UserQuery exposing (populate, sendRequestUser)
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
    SendGetUserRequest -> ( model, sendRequestUser model.form model.location)
    GetUser(Ok user) ->({model| foundUser = Just user}, Cmd.none)
    GetUser (Err err) -> (Debug.log "User failed to fetch!" {model | foundUser = Nothing}, Cmd.none)
    GetGroupForUser (Ok group) ->
      ({ model | group = Just group }, Cmd.none)
    GetGroupForUser (Err err) ->
      (Debug.log "Group failed to fetch!" model, Cmd.none)
