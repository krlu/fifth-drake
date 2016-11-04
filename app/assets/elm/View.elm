module View exposing (..)

import Html exposing (..)
import Html.App
import Html.Attributes exposing (..)
import Minimap.Minimap as Minimap
import TagScroller.TagScroller as TagScroller
import Timeline.Timeline as Timeline
import Types exposing (..)

view : Model -> Html Msg
view model =
  let
      timeline = Html.App.map TimelineMsg <| Timeline.view model.timeline
      minimap = Html.App.map MinimapMsg <| Minimap.view model.minimap
      tagScroller = Html.App.map TagScrollerMsg <| TagScroller.view model.tagScroller
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

