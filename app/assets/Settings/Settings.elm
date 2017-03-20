module Settings exposing (..)

import Html exposing (..)
import Html.CssHelpers exposing (withNamespace)
import NavbarCss exposing (CssClass(..), namespace)

{id, class, classList} = withNamespace namespace

type alias Model =
  {
  }

type alias Flags =
  {
  }

init : Flags -> ( Model, Cmd Msg )
init flags =
  ( {
    }
  , Cmd.none
  )

type Msg = Unit

view : Model -> Html Msg
view model = div [] [ text "hello world"]

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = (model, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

main : Program Flags Model Msg
main =
  Html.programWithFlags
  { init = init
  , update = update
  , view = view
  , subscriptions = subscriptions
  }
