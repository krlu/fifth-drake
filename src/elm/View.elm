module View exposing (view)

import Css exposing (..)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (on)
import Json.Decode as Json
import Messages exposing (Msg(KnobGrab))
import Models exposing (Model, getCurrentValue)
import Mouse

styles = Css.asPairs >> Html.Attributes.style

view : Model -> Html Msg
view model =
  let
    value = getCurrentValue model
  in
    div [ class "timeline" ]
      [ div [ class "bar"
            , styles [ width <| (model.maxVal |> toFloat |> px)
                     ]
            ]
            []
      , div [ on "mousedown" (Json.map KnobGrab Mouse.position)
            , class "knob"
            , styles [ left <| (value |> toFloat |> px)
                     ]
            ]
            []
      ]
