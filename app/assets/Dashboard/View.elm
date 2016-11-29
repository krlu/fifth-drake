module View exposing (..)

import DashboardCss exposing (CssClass(..), namespace)
import GameModel exposing (GameLength, Timestamp)
import Html exposing (..)
import Html.App
import Html.CssHelpers exposing (withNamespace)
import Minimap.Minimap as Minimap
import TagScroller.TagScroller as TagScroller
import Timeline.Timeline as Timeline
import Types exposing (..)

{id, class, classList} = withNamespace namespace

view : Model -> Html Msg
view model =
  let
      timeline =
        Timeline.view model.timestamp model.gameLength model.timeline
        |> Html.App.map TimelineMsg
      minimap = Minimap.view model.minimap model.gameData model.timestamp
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

