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
    playerIcons : List(Html Msg)
    playerIcons =
      model.gameData
      |> (\{blueTeam, redTeam} ->
          let
            teamToPlayerIcons arr =
              arr
              |> Array.toList
              |> List.filterMap (\player ->
                player.state
                |> Array.get model.timestamp
                |> Maybe.map (\state ->
                  div
                    [ class "playerIcon"
                    , styles
                      [ left (model.width * (state.position.x / model.mapWidth)|> px)
                      , bottom (model.height * (state.position.y / model.mapHeight)|> px)
                      ]
                    ]
                    []
                  )
                )
          in
            (teamToPlayerIcons blueTeam) ++
            (teamToPlayerIcons redTeam)
          )
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
