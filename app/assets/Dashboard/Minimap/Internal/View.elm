module Minimap.Internal.View exposing (..)

import Array
import Collage exposing (collage, defaultLine, path, toForm, traced)
import Css exposing (bottom, left, property, px)
import Element exposing (toHtml)
import Html exposing (..)
import Html.Attributes exposing (src, draggable)
import Html.CssHelpers exposing (withNamespace)
import Maybe exposing (andThen)
import Minimap.Css exposing (CssClass(..), minimapHeight, minimapWidth, namespace)
import Minimap.Types exposing (Model)
import StyleUtils exposing (styles)
import GameModel exposing (Data, Team, Timestamp)
import Types exposing (TimeSelection(..))

{id, class, classList} = withNamespace namespace

view : Model -> Data -> TimeSelection -> Html a
view model data selection =
  let
    timestamp : Timestamp
    timestamp =
      case selection of
        Instant t -> t
        Range (_, end) -> end

    playerIcons : List (Html a)
    playerIcons =
      data
      |> (\{blueTeam, redTeam} ->
          let
            teamToPlayerIcons : Team -> List (Html a)
            teamToPlayerIcons team =
              team.players
              |> Array.toList
              |> List.filterMap (\player ->
                player.state
                |> Array.get timestamp
                |> Maybe.map (\state ->
                  div
                    [ class [PlayerIcon]
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
            (teamToPlayerIcons blueTeam) ++
            (teamToPlayerIcons redTeam)
          )
--
--    playerPaths : List (Html a)
--    playerPaths =
--        case selection of
--          Instant t -> []
--          Range (start, end) ->
--            data
--            |> (\{blueTeam, redTeam} ->
--                let
--                  teamToPlayerPaths : Team -> List (Html a)
--                  teamToPlayerPaths team =
--                    team.players
--                    |> Array.toList
--                    |> List.filterMap (\player ->
--                      player.state
--                      -- Might need to do start - 1
--                      |> List.drop (start)
--                      |> List.take (end - start)
--                      -- This is wrong, since origin for Collage is at center of element and not bottom left corner
--                      |> List.map (\state ->
--                        (minimapWidth * (state.position.x / model.mapWidth),
--                         minimapHeight * (state.position.y / model.mapHeight)
--                        )
--                      )
--                      -- Solid black line for player paths, can change later as necessary
--                      |> Maybe.map (\states ->
--                        path states
--                          |> traced defaultLine
--                          |> collage model.mapWidth model.mapHeight
--                          |> toHtml
--                      )
--                    )
--                in
--                  (teamToPlayerPaths blueTeam) ++
--                  (teamToPlayerPaths redTeam)
--               )

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
--        ++ playerPaths
      )
