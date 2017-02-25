module Minimap.Internal.View exposing (..)

import Animation
import Array
import Collage exposing (Form, Path, collage, defaultLine, path, toForm, traced)
import Css exposing (backgroundImage, url)
import Dict
import Element exposing (toHtml)
import Html exposing (..)
import Html.Attributes exposing (src, draggable)
import Html.CssHelpers exposing (style, withNamespace)
import Minimap.Css exposing (CssClass(..), namespace)
import Minimap.Types exposing (Model)
import GameModel exposing (..)
import StyleUtils exposing (styles)

{id, class, classList} = withNamespace namespace

view : Model -> Data -> Html a
view model data =
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

playerPaths : Model -> Data -> Timestamp -> Timestamp -> List (Html a)
playerPaths model data start end =
  let
    playerPaths =
      data |>
      (\{blueTeam, redTeam} ->
        [ Debug.log "" (teamToPlayerPaths blueTeam model start end)
        , Debug.log "" (teamToPlayerPaths redTeam model start end)
        ]
      )
  in
    playerPaths

teamToPlayerPaths : Team -> Model -> Timestamp -> Timestamp -> Html a
teamToPlayerPaths team model start end =
  team.players
  |> Array.toList
  |> List.map (\player -> (
    player.state
    |> Array.toList
    -- Might need to do start - 1/
    |> List.drop start
    |> List.take (end - start)
    -- This is wrong, since origin for Collage is
    -- at center of element and not bottom left corner
    |> List.map (\state ->
      (model.mapWidth * (state.position.x / model.mapWidth),
       model.mapHeight * (state.position.y / model.mapHeight)
      )
    ))
  )
  -- Solid black line for player paths, can change later as necessary
  |> List.map (\states ->
    path states
    |> traced defaultLine)
  |> collage (ceiling model.mapWidth) (ceiling model.mapHeight)
  |> toHtml
