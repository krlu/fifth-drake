module Subscriptions exposing (..)

import Messages exposing (Msg(..))
import Models exposing (Model)
import Timeline.Subscriptions as TSub

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.map TimelineMsg <| TSub.subscriptions model.timeline
