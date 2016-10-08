module Timeline.View exposing (view)

import Css exposing (left, px)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick)
import Json.Decode as Json
import Mouse
import StyleUtils exposing (..)
import Timeline.Messages exposing (Msg(KnobGrab, BarClick, PlayPause))
import Timeline.Models exposing (..)

view : Model -> Html Msg
view model =
  let
    playImg = -- Yes this is intentional
      case model.status of
        Play -> model.pauseButton
        Pause -> model.playButton
    pxs = getCurrentPx model
  in
    div [ class "controls" ]
      [ div [ class "timeline"
            ]
          [ div [ class "bar"
                , styles [ Css.width (model.width |> px)
                         ]
                , on "mousedown" (Json.map BarClick Mouse.position)
                ]
                []
          , div [ on "mousedown" (Json.map KnobGrab Mouse.position)
                , class "knob"
                , styles [ left (pxs |> px)
                         ]
                ]
                []
          ]
      , div [ class "vdivider" ] []
      , button [ class "play-button"
               , onClick PlayPause
               ]
          [ img [ class "play-pause-img"
                , src playImg
                ]
              []
          ]
      ]
