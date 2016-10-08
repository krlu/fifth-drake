module View exposing (..)

import Html exposing (..)
import Html.App
import Html.Attributes exposing (..)
import Messages exposing (Msg(..))
import Minimap.View as MView
import Models exposing (Model)
import Timeline.Models exposing (getCurrentValue)
import Timeline.View as TView

view : Model -> Html Msg
view model =
  let
      timeline = Html.App.map TimelineMsg <| TView.view model.timeline
      minimap = Html.App.map MinimapMsg <| MView.view model.minimap
  in
      div []
        [ minimap
        , div [ class "hdivider" ] []
        , timeline
        , p [] [ (Html.text << toString << getCurrentValue) model.timeline ]
        , p [] [ (Html.text << toString) model.minimap.timestamp ]
        ]
