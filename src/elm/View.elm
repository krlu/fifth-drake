module View exposing (view)

import Html exposing (Html, div, text)
import Html.Attributes exposing (..)
import Html.Events exposing (on)
import Json.Decode as Json
import Messages exposing (Msg(KnobGrab))
import Models exposing (Model, getCurrentValue)
import Mouse

(=>) = (,)

view : Model -> Html Msg
view model =
  let
    value = getCurrentValue model
  in
    div [ class "timeline" ]
      [ div [ class "bar"
            , style [ "width" => (model.maxVal |> px)
                    ]
            ]
            []
      , div [ on "mousedown" (Json.map KnobGrab Mouse.position)
            , class "knob"
            , style [ "left" => (value |> px)
                    ]
            ]
            []
      ]

px : Int -> String
px i = i
     |> toString
     |> \x -> x ++ "px"
