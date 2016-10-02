module Subscriptions exposing (..)

import Models exposing (Model)
import Messages exposing (Msg(..))
import Timeline.Subscriptions as TSub

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.map TimelineMsg <| TSub.subscriptions model.timeline
