module Main exposing (..)

import Html.App
import Messages exposing (Msg(..))
import Minimap.Populate as Populate
import Models exposing (Model, Flags, initialModel)
import Subscriptions
import Task
import Update
import View

init : Flags -> (Model, Cmd Msg)
init flags =
  ( initialModel flags
  , Cmd.map MinimapMsg Populate.populate
  )

main : Program Flags
main =
  Html.App.programWithFlags
    { init = init
    , view = View.view
    , update = Update.update
    , subscriptions = Subscriptions.subscriptions
    }
