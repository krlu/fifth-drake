module Settings exposing (..)

import Html exposing (..)
import Html.Attributes exposing (placeholder)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (onClick, onInput)
import Http
import NavbarCss exposing (CssClass(..), namespace)
import Internal.UserQuery exposing (populate, sendRequestUser)
import Navigation exposing (Location)
import SettingsTypes exposing (..)

{id, class, classList} = withNamespace namespace

init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
  ( { group = Nothing
    , form =
      { email = ""
      }
    , location = location
    , foundUser = Nothing
    }
  , populate location
  )

view : Model -> Html Msg
view model =
  div []
    [ input
      [ placeholder "Search user"
      , onInput UpdateSearchForm
      ]
      []
    , button
      [ onClick SendGetUserRequest]
      [ text "find user" ]
    ]

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
      ({ model | group = Just <| Debug.log "" group }, Cmd.none)
    GetGroupForUser (Err err) ->
      (Debug.log "Group failed to fetch!" model, Cmd.none)


subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

main : Program Flags Model Msg
main =
  Navigation.programWithFlags
  LocationUpdate
  { init = init
  , update = update
  , view = view
  , subscriptions = subscriptions
  }
