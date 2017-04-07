module Minimap.Internal.View exposing (view)

import Animation
import Array
import Collage exposing (Form, Path, collage, defaultLine, path, toForm, traced)
import Css exposing (backgroundImage, url)
import Dict
import Element exposing (toHtml)
import Html exposing (..)
import Html.Attributes exposing (draggable, src, style)
import Html.CssHelpers exposing (withNamespace)
import Minimap.Css exposing (CssClass(..), minimapHeight, minimapWidth, namespace)
import Minimap.Types exposing (Model)
import GameModel exposing (..)
import Navbar exposing (Icon)
import StyleUtils exposing (styles)
import Types exposing (ObjectiveEvent)

{id, class, classList} = withNamespace namespace

view : Model -> Data -> List ObjectiveEvent -> Timestamp -> Html a
view model data objectives timestamp=
  let
    inhibsHtml =
      List.map (buildingToHtml model model.blueInhibitorKillIcon model.redInhibitorKillIcon) <|
      List.filter (\obj ->obj.unitKilled == "Inhibitor") <|
      List.filter (\obj -> obj.timestamp < timestamp) objectives

    towersHtml =
      List.map (buildingToHtml model model.blueTowerKillIcon model.redTowerKillIcon) <|
      List.filter (\obj -> isTurretKill obj) <|
      List.filter (\obj -> obj.timestamp < timestamp) objectives

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
        ++ playerIcons ++ towersHtml ++ inhibsHtml
      )

buildingToHtml : Model -> Icon -> Icon -> ObjectiveEvent -> Html a
buildingToHtml model blue red objective =
  let
    bottom = minimapHeight * (objective.position.y / model.mapHeight)
    left = minimapWidth * (objective.position.x / model.mapWidth)
    styles =
      style
      [ ("bottom", (toString bottom) ++ "px")
      , ("left", (toString left) ++ "px" )
      , ("position", "absolute" )
      ]
  in
    case (colorOfKilled objective) of
      Blue -> img [ src red, styles] []
      Red -> img [ src blue, styles] []


colorOfKilled : ObjectiveEvent -> Side
colorOfKilled objective =
    case objective.killerId of
      200 -> Red
      100 -> Blue
      _ -> Debug.log "ERROR, ID WAS NOT 100 NOR 200, ARE YOU SURE THIS IS A BUILDING KILL?" Red

isTurretKill : ObjectiveEvent -> Bool
isTurretKill objective =
  case objective.unitKilled of
    "OuterTurret" -> True
    "InnerTurret" ->  True
    "BaseTurret" -> True
    "NexusTurret" -> True
    _ -> False


playerPaths : Model -> Data -> Timestamp -> Timestamp -> List (Html a)
playerPaths model data start end =
  let
    playerPaths =
      data |>
      (\{blueTeam, redTeam} ->
        [ teamToPlayerPaths blueTeam model start end
        , teamToPlayerPaths redTeam model start end
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
