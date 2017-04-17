module Minimap.Internal.View exposing (view)

import Animation
import Array
import Collage exposing (Form, Path, collage, defaultLine, path, toForm, traced)
import Css exposing (backgroundImage, url)
import Dict
import Element exposing (toHtml)
import Graph.Internal.PlotView exposing (zip)
import Html exposing (..)
import Html.Attributes exposing (draggable, src, style)
import Html.CssHelpers exposing (withNamespace)
import Minimap.Css exposing (CssClass(..), minimapHeight, minimapWidth, namespace)
import Minimap.Types exposing (Building(Inhibitor, Tower), State)
import GameModel exposing (..)
import Navbar exposing (Icon)
import Set exposing (Set)
import StyleUtils exposing (styles)
import Types exposing (ObjectiveEvent, Model)

{id, class, classList} = withNamespace namespace

view : Model -> Html a
view model =
  let
    minimap = model.minimap
    data = model.game.data
    objectives = model.events
    timestamp = model.timestamp
    selectedPlayers = model.playerDisplay.selectedPlayers
    pathLength = model.pathLength
    hoveredPlayer = model.playerDisplay.hoveredPlayer
    highlightedPlayers = model.tagCarousel.highlightedPlayers

    inhibsHtml =
      List.map (killedBuildingToHtml minimap minimap.blueInhibitorKillIcon minimap.redInhibitorKillIcon) <|
      List.filter (\obj ->obj.unitKilled == "Inhibitor") <|
      List.filter (\obj -> obj.timestamp < timestamp) objectives

    towersHtml =
      List.map (killedBuildingToHtml minimap minimap.blueTowerKillIcon minimap.redTowerKillIcon) <|
      List.filter (\obj -> isTurretKill obj) <|
      List.filter (\obj -> obj.timestamp < timestamp) objectives

    allBuildings
      = List.map
        (buildingToHtml
          minimap minimap.blueTowerIcon
          minimap.redTowerIcon
          minimap.blueInhibitorIcon
          minimap.redInhibitorIcon) buildingPositions

    startTime = max 0 (timestamp - pathLength)
    paths = playerPaths minimap data startTime timestamp selectedPlayers
    playerIcons : List (Html a)
    playerIcons =
      Dict.toList minimap.iconStates
      |> List.map (\(playerId, iconState) ->
          div
            ([ class
              [ PlayerIcon
              , iconColor iconState playerId hoveredPlayer highlightedPlayers
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
              , src minimap.background
              , draggable "false"
              ]
            []
        ]
        ++ playerIcons ++ towersHtml ++ inhibsHtml ++ paths ++ allBuildings
      )

iconColor : State -> PlayerId -> Maybe PlayerId -> List PlayerId -> CssClass
iconColor iconState playerId hoveredPlayer highlightedPlayers =
  case hoveredPlayer of
    Nothing ->
      case (List.member playerId highlightedPlayers) of
        False -> IconColor iconState.side
        True -> HighlightedIconColor
    Just hoveredId ->
      case playerId == hoveredId of
        False -> IconColor iconState.side
        True -> HighlightedIconColor

buildingToHtml : Minimap.Types.Model -> Icon -> Icon -> Icon -> Icon -> (Float, Float, Side, Building) -> Html a
buildingToHtml model blueT redT blueH redH (x, y, side, building) =
  let
    bottom = minimapHeight * (y / model.mapHeight)
    left = minimapWidth * (x / model.mapWidth)
    styles =
      style
      [ ("bottom", (toString bottom) ++ "px")
      , ("left", (toString left) ++ "px" )
      , ("position", "absolute" )
      , ("height", "30px")
      , ("z-index", "0")
      ]
  in
    case (side, building) of
      (Blue, Tower) -> img [ src blueT, styles] []
      (Red, Tower) -> img [ src redT, styles] []
      (Blue, Inhibitor) -> img [ src blueH, styles] []
      (Red, Inhibitor) -> img [ src redH, styles] []

killedBuildingToHtml : Minimap.Types.Model -> Icon -> Icon -> ObjectiveEvent -> Html a
killedBuildingToHtml model blue red objective =
  let
    bottom = minimapHeight * (objective.position.y / model.mapHeight)
    left = minimapWidth * (objective.position.x / model.mapWidth)
    loc = Debug.log "" (objective.position.x, objective.position.y)
    styles =
      style
      [ ("bottom", (toString bottom) ++ "px")
      , ("left", (toString left) ++ "px" )
      , ("position", "absolute" )
      , ("height", "30px")
      , ("z-index", "1")
      ]
  in
    case (colorOfKilled objective) of
      Blue -> img [ src red, styles] []
      Red -> img [ src blue, styles] []

{-- killed should be opposite color of killer -}
colorOfKilled : ObjectiveEvent -> Side
colorOfKilled objective =
    case objective.killerId of
      200 -> Blue
      100 -> Red
      _ -> Debug.log "ERROR, ID WAS NOT 100 NOR 200, ARE YOU SURE THIS IS A BUILDING KILL?" Red

isTurretKill : ObjectiveEvent -> Bool
isTurretKill objective =
  case objective.unitKilled of
    "OuterTurret" -> True
    "InnerTurret" ->  True
    "BaseTurret" -> True
    "NexusTurret" -> True
    _ -> False

playerPaths : Minimap.Types.Model -> Data -> Timestamp -> Timestamp -> Set PlayerId -> List (Html a)
playerPaths model data start end selectedPlayers =
  let
    playerPaths =
      data |>
      (\{blueTeam, redTeam} ->
        [ teamToPlayerPaths blueTeam model start end selectedPlayers Blue
        , teamToPlayerPaths redTeam model start end selectedPlayers Red
        ]
      )
      |> List.concatMap (\list -> list)
  in
    playerPaths

teamToPlayerPaths : Team -> Minimap.Types.Model -> Timestamp -> Timestamp -> Set PlayerId -> Side -> List (Html a)
teamToPlayerPaths team model start end selectedPlayers side =
  let
    diff = end - start - 1
    opacities = List.range 1 diff |> List.map (\val -> (toFloat val)/(toFloat diff))
  in
    team.players
    |> Array.toList
    |> List.filter (\player -> Set.member player.id selectedPlayers)
    |> List.map (\player -> (
      player.state
      |> Array.toList
      |> List.drop start
      |> List.take diff
      |> List.map (\state ->
        (minimapWidth * (state.position.x / model.mapWidth),
         minimapHeight * (state.position.y / model.mapHeight)
        ))
      |> zip opacities
      |> List.map (\(op, (x,y)) -> div [getPosStyle x y op side] [])
      )
    )
    |> List.concatMap (\list -> list)

getPosStyle : Float -> Float -> Float -> Side -> Attribute msg
getPosStyle x y opacity side =
  let
    color =
      case side of
        Blue -> "blue"
        Red -> "red"
  in
   style
    [ ("bottom", (toString y) ++ "px")
    , ("left", (toString x) ++ "px")
    , ("position", "absolute")
    , ("width", "10px")
    , ("height", "10px")
    , ("background", color)
    , ("border-radius", "10px")
    , ("opacity", toString opacity)
    ]

buildingPositions : List (Float, Float, Side, Building)
buildingPositions =
  [ (13604,11316, Red, Inhibitor) -- red Inhib
  , (11598,11667, Red, Inhibitor) -- red Inhib
  , (3203,3208, Blue, Inhibitor) -- blue Inhib
  , (12611,13084, Red, Tower)
  , (13052,12612, Red, Tower)
  , (13624,10572, Red, Tower)
  , (13327,8226, Red, Tower)
  , (11134,11207, Red, Tower)
  , (9767,10113, Red, Tower)
  , (7943,13411, Red, Tower)
  , (6919,1483, Blue, Tower)
  , (3651,3696, Blue, Tower)
  , (5048,4812, Blue, Tower)
  , (1512,6699, Blue, Tower)
  , (8955,8510, Red, Tower)
  , (5846,6396, Blue, Tower)
  , (4318,13875, Red, Tower)
  , (10504,1029, Blue, Tower)
  , (13866,4505, Red, Tower)
  , (981,10441, Blue, Tower)
  , (1171,3571, Blue, Inhibitor) -- blue Inhib
  , (2177,1807, Blue, Tower)
  , (1748,2270, Blue, Tower)
  , (1169,4287, Blue, Tower)
  , (10481,13650, Red, Tower)
  , (3452,1236, Blue, Inhibitor)-- blue Inhib
  , (4281,1253, Blue, Tower)
  , (11261,13676, Red, Inhibitor) -- red Inhib
  ]
