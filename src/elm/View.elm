module View exposing (..)

import Html exposing (..)
import Html.App
import Messages exposing (Msg(..))
import Models exposing (Model)
import Timeline.View as TView

view : Model -> Html Msg
view model =
  let
      timeline = Html.App.map TimelineMsg <| TView.view model.timeline
  in
      div []
        [ timeline
        ]
