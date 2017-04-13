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
import Minimap.Types exposing (Model, State)
import GameModel exposing (..)
import Navbar exposing (Icon)
import Set exposing (Set)
import StyleUtils exposing (styles)
import Types exposing (ObjectiveEvent)

{id, class, classList} = withNamespace namespace

view : Model -> Data -> List ObjectiveEvent -> Timestamp -> Set PlayerId -> Int -> Maybe PlayerId -> Html a
view model data objectives timestamp selectedPlayers pathLength hoveredPlayer =
  let
    inhibsHtml =
      List.map (buildingToHtml model model.blueInhibitorKillIcon model.redInhibitorKillIcon) <|
      List.filter (\obj ->obj.unitKilled == "Inhibitor") <|
      List.filter (\obj -> obj.timestamp < timestamp) objectives

    towersHtml =
      List.map (buildingToHtml model model.blueTowerKillIcon model.redTowerKillIcon) <|
      List.filter (\obj -> isTurretKill obj) <|
      List.filter (\obj -> obj.timestamp < timestamp) objectives

    startTime = max 0 (timestamp - pathLength)
    paths = Debug.log "" <| playerPaths model data startTime timestamp selectedPlayers
    playerIcons : List (Html a)
    playerIcons =
      Dict.toList model.iconStates
      |> List.map (\(playerId, iconState) ->
          div
            ([ class
              [ PlayerIcon
              , iconColor iconState playerId hoveredPlayer
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
        ++ playerIcons ++ towersHtml ++ inhibsHtml ++ paths
      )

iconColor : State -> PlayerId -> Maybe PlayerId -> CssClass
iconColor iconState playerId hoveredPlayer =
 case hoveredPlayer of
  Nothing -> IconColor iconState.side
  Just hoveredId ->
    case playerId == hoveredId of
      False -> IconColor iconState.side
      True -> HighlightedIconColor


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

playerPaths : Model -> Data -> Timestamp -> Timestamp -> Set PlayerId -> List (Html a)
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

teamToPlayerPaths : Team -> Model -> Timestamp -> Timestamp -> Set PlayerId -> Side -> List (Html a)
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
