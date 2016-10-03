module Timeline.View exposing (view)

import Css exposing (..)
import Html exposing (Html, div, p)
import Html.Attributes exposing (class)
import Html.Events exposing (on)
import Json.Decode as Json
import Mouse
import StyleUtils exposing (..)
import Timeline.Messages exposing (Msg(KnobGrab, BarClick))
import Timeline.Models exposing (Model, getCurrentPx, getCurrentValue)

view : Model -> Html Msg
view model =
  let
    pxs = getCurrentPx model
  in
    div [ class "timeline"
        ]
      [ div [ class "bar"
            , styles [ width (model.width |> px)
                     ]
            , on "click" (Json.map BarClick Mouse.position)
            ]
            []
      , div [ on "mousedown" (Json.map KnobGrab Mouse.position)
            , class "knob"
            , styles [ left (pxs |> px)
                     ]
            ]
            []
      , p [] [ (Html.text << toString << getCurrentValue) model ]
      ]
