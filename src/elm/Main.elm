module Main exposing (..)

import Html.App
import Messages exposing (Msg(..))
import Minimap.Populate as Populate
import Models exposing (Model, initialModel)
import Subscriptions
import Task
import Update
import View

init : (Model, Cmd Msg)
init = ( initialModel
       , Cmd.map MinimapMsg Populate.populate
       )

main : Program Never
main = Html.App.program { init = init
                        , view = View.view
                        , update = Update.update
                        , subscriptions = Subscriptions.subscriptions
                        }
