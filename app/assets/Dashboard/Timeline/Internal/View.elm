module Timeline.Internal.View exposing (view)

import Css exposing (left, px)
import DashboardCss
import Html exposing (..)
import Html.Attributes exposing (src)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (on, onClick)
import Json.Decode as Json
import Mouse
import StyleUtils exposing (..)
import Timeline.Css exposing (CssClass(..), namespace, timelineWidth)
import Timeline.Internal.ModelUtils exposing(getCurrentPx)
import Timeline.Types exposing (Msg(KnobGrab, BarClick, PlayPause), Model, Status(..))

{id, class, classList} = withNamespace namespace

view : Model -> Html Msg
view model =
  let
    playImg = -- Yes this is intentional
      case model.status of
        Play -> model.pauseButton
        Pause -> model.playButton
    pxs = getCurrentPx model
  in
    div [ class [Controls] ]
      [ div [ class [Timeline]
            ]
          [ div [ class [Bar]
                , styles [ Css.width (timelineWidth |> px)
                         ]
                , on "mousedown" (Json.map BarClick Mouse.position)
                ]
                []
          , div [ on "mousedown" (Json.map KnobGrab Mouse.position)
                , class [Knob]
                , styles [ left (pxs |> px)
                         ]
                ]
                []
          ]
      , div [ (withNamespace DashboardCss.namespace).class [DashboardCss.Vdivider] ] []
      , button [ class [PlayButton]
               , onClick PlayPause
               ]
          [ img [ class [PlayPauseImg]
                , src playImg
                ]
              []
          ]
      ]
