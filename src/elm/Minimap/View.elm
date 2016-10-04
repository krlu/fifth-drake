module Minimap.View exposing (..)

import Css exposing (left, bottom, px)
import Html exposing (..)
import Html.Attributes exposing (..)
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
      (
        [ img [ class "background"
              , src "src/img/map.jpg"
              ]
            []
        ]
        ++ playerIcons
      )
