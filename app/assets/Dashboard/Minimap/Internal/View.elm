module Minimap.Internal.View exposing (..)

import Array
import Css exposing (left, bottom, px)
import Html exposing (..)
import Html.Attributes exposing (src, draggable)
import Html.CssHelpers exposing (withNamespace)
import Maybe exposing (andThen)
import Minimap.Css exposing (CssClass(..), minimapHeight, minimapWidth, namespace)
import Minimap.Types exposing (Msg, Model)
import StyleUtils exposing (styles)

{id, class, classList} = withNamespace namespace

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
                    [ class [PlayerIcon]
                    , styles
                      [ left (minimapWidth * (state.position.x / model.mapWidth)|> px)
                      , bottom (minimapHeight * (state.position.y / model.mapHeight)|> px)
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
    div [ class [Minimap]
        ]
      (
        [ img [ class [Background]
              , src model.background
              , draggable "false"
              ]
            []
        ]
        ++ playerIcons
      )
