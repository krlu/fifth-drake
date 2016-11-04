module Minimap.Internal.View exposing (..)

import Array
import Css exposing (left, bottom, px)
import Html exposing (..)
import Html.Attributes exposing (..)
import Maybe exposing (andThen)
import Minimap.Types exposing (Msg, Model)
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
              , src model.background
              , draggable "false"
              ]
            []
        ]
        ++ playerIcons
      )
