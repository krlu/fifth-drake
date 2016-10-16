module View exposing (..)

import Html exposing (..)
import Html.App
import Html.Attributes exposing (..)
import Messages exposing (Msg(..))
import Minimap.View as MView
import Models exposing (Model)
import TagScroller.View as TagView
import Timeline.Models exposing (getCurrentValue)
import Timeline.View as TView

view : Model -> Html Msg
view model =
  let
      timeline = Html.App.map TimelineMsg <| TView.view model.timeline
      minimap = Html.App.map MinimapMsg <| MView.view model.minimap
      tagScroller = Html.App.map TagScrollerMsg <| TagView.view model.tagScroller
  in
      div []
        [ div [ class "content" ]
            [ minimap
            , div [ class "vdivider" ] []
            , tagScroller
            ]
        , div [ class "hdivider" ] []
        , timeline
        ]

