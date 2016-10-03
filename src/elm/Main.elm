module Main exposing (..)

import Html.App
import Messages exposing (Msg)
import Models exposing (Model, initialModel)
import Subscriptions
import Update
import View

init : (Model, Cmd Msg)
init = (initialModel, Cmd.none)

main : Program Never
main = Html.App.program { init = init
                        , view = View.view
                        , update = Update.update
                        , subscriptions = Subscriptions.subscriptions
                        }
