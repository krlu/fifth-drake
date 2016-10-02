module Timeline.View exposing (view)

import Css exposing (..)
import Html exposing (Html, div, text, p)
import Html.Attributes exposing (class)
import Html.Events exposing (on)
import Json.Decode as Json
import Timeline.Messages exposing (Msg(KnobGrab, BarClick))
import Timeline.Models exposing (Model, getCurrentPx)
import Mouse

styles = Css.asPairs >> Html.Attributes.style

view : Model -> Html Msg
view model =
  let
    value = getCurrentPx model
  in
    div [ class "timeline"
        ]
      [ div [ class "bar"
            , styles [ width <| (model.width |> px)
                     ]
            , on "click" (Json.map BarClick Mouse.position)
            ]
            []
      , div [ on "mousedown" (Json.map KnobGrab Mouse.position)
            , class "knob"
            , styles [ left <| (value |> px)
                     ]
            ]
            []
      ]
