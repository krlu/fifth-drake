module TeamDisplay.TeamDisplay exposing (view)

import Array
import Css exposing (px)
import GameModel exposing (Player, Side(Blue, Red), Team, Timestamp)
import Html exposing (..)
import Html.Attributes exposing (src, style)
import Html.CssHelpers exposing (withNamespace)
import TeamDisplay.Css exposing (CssClass(..), namespace)
import TeamDisplay.Types exposing (Model)
import Types exposing (ObjectiveEvent)

{id, class, classList} = withNamespace namespace

view : String -> Team -> Timestamp -> List ObjectiveEvent -> Model -> Side -> Html a
view name team timestamp objectives model side =
  let
    players = Array.toList team.players
    dragonObjectives =
      List.filter (\obj -> isDragonKill obj) <|
      List.filter (\obj -> teamKilledObjective players obj) <|
      List.filter (\obj -> obj.timestamp < timestamp) objectives
    objectivesHtml =
      List.map (objectiveToHtml model side (List.length dragonObjectives)) <| dragonObjectives
    teamState =
      Array.get timestamp team.teamStates
      |> Maybe.map (\{turrets, dragons, barons} ->
        { dragons = toString dragons
        , barons = toString barons
        , turrets = toString turrets
        })
      |> Maybe.withDefault
        { dragons = "N/A"
        , barons = "N/A"
        , turrets = "N/A"
        }
    stats : String -> String -> Html a
    stats value label =
      p
        []
        [ text <| value ++ " "
        , span
          [class [Label] ]
          [text label]
        ]
    teamStatsHtml =
      div [class [TeamDisplay] ]
        [ h1 []
          [ text name ]
        , div [ class [TeamStats] ]
          [ stats teamState.dragons "dragons"
          , stats teamState.barons "barons"
          , stats teamState.turrets "turrets"
          ]
        ]
    dragonHtml =
      case side of
        Red ->
          div [class [DragonDisplay]]
            objectivesHtml
        Blue ->
          div [class [DragonDisplay]]
            <| List.reverse objectivesHtml
    containedHtml =
      case side of
        Red -> [teamStatsHtml, dragonHtml]
        Blue -> [dragonHtml, teamStatsHtml]
  in
    div [class [TeamDisplayContainer]]
      containedHtml

isDragonKill : ObjectiveEvent -> Bool
isDragonKill objective =
  case objective.unitKilled of
    "WaterDragon" -> True
    "FireDragon" ->  True
    "EarthDragon" -> True
    "AirDragon" ->  True
    "ElderDragon" ->  True
    _ -> False

teamKilledObjective : List Player -> ObjectiveEvent -> Bool
teamKilledObjective players objective =
  List.map (\player -> player.participantId) players
  |> List.member objective.killerId

objectiveToHtml : Model -> Side -> Int -> ObjectiveEvent -> Html a
objectiveToHtml model side numDragons objective=
  let
    pos =
      case side of
        Blue -> style [("left", (toString <| 160 - (30 * (numDragons-1))) ++ "px")]
        Red -> style []
  in
    case objective.unitKilled of
      ("WaterDragon") ->  img [ src model.waterDragonIcon, class [DragonImage], pos] []
      ("FireDragon") ->  img [ src model.fireDragonIcon, class [DragonImage], pos] []
      ("EarthDragon") ->  img [ src model.earthDragonIcon, class [DragonImage], pos] []
      ("AirDragon") ->  img [ src model.airDragonIcon, class [DragonImage], pos] []
      ("ElderDragon") ->  img [ src model.elderDragonIcon, class [DragonImage], pos] []
      _ -> div [] []
