module View exposing (..)

import Html exposing (..)
import Html.App
import Messages exposing (Msg(..))
import Models exposing (Model)
import Timeline.View as TView
import Minimap.View as MView

view : Model -> Html Msg
view model =
  let
      timeline = Html.App.map TimelineMsg <| TView.view model.timeline
      minimap = Html.App.map MinimapMsg <| MView.view model.minimap
  in
      div []
        [ minimap
        , timeline
        ]
