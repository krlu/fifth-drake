module Homepage exposing (..)

import HomeUpdate as Update
import HomePopulate as Populate
import HomeView as View
import HomeTypes exposing (..)
import Array exposing (Array, set)
import Dict
import Date exposing (Date, Month(..), day, fromTime, month, year)
import GameModel exposing (GameLength)
import Html exposing (Html, a, div, text)
import Html.Attributes exposing (href, style)
import Http
import Json.Decode exposing (..)
import Navigation exposing (Location)

init : Flags -> Location -> (Model, Cmd Msg)

init flags location =
  ( { games = []
    , query = ""
    , location = location
    }
  , Populate.populate location
  )

view : Model -> Html Msg
view model = View.view model

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = Update.update msg model

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

main : Program Flags Model Msg
main =
  Navigation.programWithFlags
    LocationUpdate
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
