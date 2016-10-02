module Main exposing (..)

import Html exposing (Html, div, text)
import Html.App
import Timeline.Messages exposing (Msg)
import Timeline.Models exposing (Model, initialModel)
import Timeline.Subscriptions
import Timeline.Update
import Timeline.View

init : (Model, Cmd Msg )
init = (initialModel, Cmd.none)

main : Program Never
main = Html.App.program { init = init
                        , view = Timeline.View.view
                        , update = Timeline.Update.update
                        , subscriptions = Timeline.Subscriptions.subscriptions
                        }
