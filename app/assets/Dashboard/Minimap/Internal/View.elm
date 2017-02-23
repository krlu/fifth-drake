module Minimap.Internal.View exposing (..)

import Animation
import Collage exposing (collage, defaultLine, path, toForm, traced)
import Css exposing (backgroundImage, url)
import Dict
import Html exposing (..)
import Html.Attributes exposing (src, draggable)
import Html.CssHelpers exposing (style, withNamespace)
import Minimap.Css exposing (CssClass(..), namespace)
import Minimap.Types exposing (Model)
import GameModel exposing (..)
import StyleUtils exposing (styles)

{id, class, classList} = withNamespace namespace

view : Model -> Html a
view model =
  let
    playerIcons : List (Html a)
    playerIcons =
      Dict.values model.iconStates
      |> List.map (\iconState ->
          div
            ([ class
              [ PlayerIcon
              , IconColor iconState.side
              ]
            , styles
              [ backgroundImage (url iconState.img)
              ]
            ]
            ++ (Animation.render iconState.style))
            []
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

--playerPaths : List (Html a)
--playerPaths =
--  case selection of
--    Instant t -> []
--    Range (start, end) ->
--      data
--      |> (\{blueTeam, redTeam} ->
--          let
--            teamToPlayerPaths : Team -> List (Html a)
--            teamToPlayerPaths team =
--              team.players
--              |> Array.toList
--              |> List.filterMap (\player ->
--                player.state
--                -- Might need to do start - 1
--                |> List.drop (start)
--                |> List.take (end - start)
--                -- This is wrong, since origin for Collage is at center of element and not bottom left corner
--                |> List.map (\state ->
--                  (minimapWidth * (state.position.x / model.mapWidth),
--                   minimapHeight * (state.position.y / model.mapHeight)
--                  )
--                )
--                -- Solid black line for player paths, can change later as necessary
--                |> Maybe.map (\states ->
--                  path states
--                    |> traced defaultLine
--                    |> collage model.mapWidth model.mapHeight
--                    |> toHtml
--                )
--              )
--          in
--            (teamToPlayerPaths blueTeam) ++
--            (teamToPlayerPaths redTeam)
--         )
