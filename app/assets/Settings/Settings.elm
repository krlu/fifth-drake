module Settings exposing (..)

import Html exposing (Html)
import Internal.UserQuery exposing (populate)
import Navigation exposing (Location)
import SettingsTypes exposing (..)
import SettingsView as View
import SettingsUpdate as Update

init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
  ( { group = Nothing
    , permissions = Nothing
    , currentUser = Nothing
    , form =
      { email = ""
      }
    , location = location
    , searchIcon = flags.searchIcon
    , addUserIcon = flags.addUserIcon
    , removeUserIcon = flags.removeUserIcon
    , updatePermissionIcon = flags.updatePermissionIcon
    }
  , populate location
  )

view : Model -> Html Msg
view model = View.view model

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = Update.update msg model

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
