module Minimap.View exposing (..)

import Array
import Css exposing (left, bottom, px)
import Html exposing (..)
import Html.Attributes exposing (..)
import Maybe exposing (andThen)
import Minimap.Messages exposing (Msg)
import Minimap.Models exposing (Model)
import StyleUtils exposing (..)

view : Model -> Html Msg
view model =
  let
    playerIcons =
      List.filterMap
        (\player ->
          Array.get model.timestamp player.state
            |> Maybe.map (\state ->
              div [ class "playerIcon"
                  , styles [ left (state.x |> px)
                           , bottom (state.y |> px)
                           ]
                  ]
               [])
        )
        model.players
  in
    div [ class "minimap"
        ]
      (
        [ img [ class "background"
              , src "src/img/map.jpg"
              , draggable "false"
              ]
            []
        ]
        ++ playerIcons
      )
