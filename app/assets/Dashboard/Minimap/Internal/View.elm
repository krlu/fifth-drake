module Minimap.Internal.View exposing (..)

import Array
import Css exposing (Color, bottom, left, property, px)
import Html exposing (..)
import Html.Attributes exposing (src, draggable)
import Html.CssHelpers exposing (withNamespace)
import Maybe exposing (andThen)
import Minimap.Css exposing (CssClass(..), minimapHeight, minimapWidth, namespace)
import Minimap.Types exposing (Model)
import StyleUtils exposing (styles)
import GameModel exposing (Data, Side(Blue, Red, Red), Team, Timestamp)

{id, class, classList} = withNamespace namespace
epsilon = 0.0000001

view : Model -> Data -> Timestamp -> Html a
view model data timestamp =
  let
    playerIcons : List (Html a)
    playerIcons =
      data
      |> (\{blueTeam, redTeam} ->
          let
            teamToPlayerIcons : Team -> Side -> List (Html a)
            teamToPlayerIcons team side =
              team.players
              |> Array.toList
              |> List.filterMap (\player ->
                player.state
                |> Array.get timestamp
                |> Maybe.andThen (\state ->
                -- filters out players who are 'dead' and have no current HP to not render
                  if state.championState.hp < epsilon
                  then Nothing
                  else Just state
                  )
                |> Maybe.map (\state ->
                  div
                    [ class
                      [ PlayerIcon
                      , IconColor side
                      ]
                    , styles
                      [ left (minimapWidth * (state.position.x / model.mapWidth)|> px)
                      , bottom (minimapHeight * (state.position.y / model.mapHeight)|> px)
                      ]
                    ]
                    [ img
                        [ class [ChampionImage]
                        , src player.championImage
                        , draggable "false"
                        ]
                        []
                    ]
                  )
                )
          in
            (teamToPlayerIcons blueTeam Blue) ++
            (teamToPlayerIcons redTeam Red)
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
