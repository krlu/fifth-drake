module View exposing (..)

import DashboardCss exposing (CssClass(..), namespace)
import Html exposing (..)
import Html.App
import Html.CssHelpers exposing (withNamespace)
import Minimap.Minimap as Minimap
import TagScroller.TagScroller as TagScroller
import Timeline.Timeline as Timeline
import TagForm.TagForm as TagForm
import Types exposing (..)

{id, class, classList} = withNamespace namespace

view : Model -> Html Msg
view model =
  let
      timeline = Html.App.map TimelineMsg <| Timeline.view model.timeline
      minimap = Html.App.map MinimapMsg <| Minimap.view model.minimap
      tagScroller = Html.App.map TagScrollerMsg <| TagScroller.view model.tagScroller
  in
      div [ class [Dashboard] ]
        [ div [ class [MapAndTags] ]
            [ minimap
            , div [ (withNamespace DashboardCss.namespace).class [Vdivider] ] []
            , tagScroller
            ]
        , div [ class [Hdivider] ] []
        , timeline
        ]

