module Minimap.View exposing (..)

import Css exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, style)
import Minimap.Models exposing (Model)
import Minimap.Messages exposing (Msg)
import StyleUtils exposing (..)

view : Model -> Html Msg
view model =
  let
    playerIcons =
      List.map
        (\player ->
          div [ class "playerIcon"
              , styles [ left (player.x |> px)
                       , bottom (player.y |> px)
                       ]
              ]
           []
        )
        model.players
  in
    div [ class "minimap"
        ]
      playerIcons
