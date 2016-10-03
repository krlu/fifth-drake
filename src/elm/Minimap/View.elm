module Minimap.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, style)
import Minimap.Models exposing (Model)
import Minimap.Messages exposing (Msg)
import StyleUtils exposing (..)

view : Model -> Html Msg
view model =
  div [ class "minimap"
      ]
    []
