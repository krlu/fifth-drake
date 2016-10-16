module Main exposing (..)

import Html.App
import Messages exposing (Msg(..))
import Minimap.Populate as MPopulate
import TagScroller.Populate as TagPopulate
import Models exposing (Model, Flags, initialModel)
import Subscriptions
import Task
import Update
import View

init : Flags -> (Model, Cmd Msg)
init flags =
  ( initialModel flags
  , Cmd.batch
      [ Cmd.map MinimapMsg MPopulate.populate
      , Cmd.map TagScrollerMsg TagPopulate.populate
      ]
  )

main : Program Flags
main =
  Html.App.programWithFlags
    { init = init
    , view = View.view
    , update = Update.update
    , subscriptions = Subscriptions.subscriptions
    }
