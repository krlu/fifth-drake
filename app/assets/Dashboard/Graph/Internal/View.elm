module Graph.Internal.View exposing (view)

import Array
import Css exposing (height, pct, width, zero)
import GameModel exposing (..)
import Graph.Internal.PlotView exposing (customHintCreator)
import Graph.Types exposing (Model, Msg(ChangeStat, PlotInteraction), Stat(Gold, HP, XP))
import Html exposing (..)
import Html.Attributes exposing (defaultValue, draggable, placeholder, placeholder, selected, src)
import Html.CssHelpers exposing (withNamespace)
import Graph.Css exposing (CssClass(..), namespace)
import Html.Events exposing (onInput)
import Plot exposing (..)
import Plot.Line exposing (stroke, strokeWidth)
import Plot.Label as Label
import Plot.Axis as Axis
import Set exposing (Set)
import String
import Tuple
import Plot.Hint

{id, class, classList} = withNamespace namespace

view : Model -> Game -> Set PlayerId -> Html Msg
view model game selectedPlayers =
  let
    start = model.start
    end = model.end
    allPlayers = (Array.toList game.data.blueTeam.players) ++  (Array.toList game.data.redTeam.players)
    bluePlayers = Array.toList game.data.blueTeam.players
                  |> List.filter (\player -> Set.member player.id selectedPlayers)
    redPlayers = Array.toList game.data.redTeam.players
                  |> List.filter (\player -> Set.member player.id selectedPlayers)
    (statFunction, highMark, labelName) =
      case model.selectedStat of
        HP -> (getHpPercent << .championState, 100, "HP%")
        Gold -> (.totalGold, getMax .totalGold (start, end) allPlayers, "Total Gold")
        XP -> (.xp << .championState,getMax (.xp << .championState) (start, end) allPlayers, "Total XP")
    blueLines = bluePlayers
              |> List.map (\player -> createLineForPlayer (start, end) player Blue game.metadata.gameLength statFunction)
    redLines = redPlayers
              |> List.map (\player -> createLineForPlayer (start, end) player Red game.metadata.gameLength statFunction)

    blueHintData = bluePlayers |> List.map (\player -> (player.ign, getColorString Blue player.role))
    redHintData = redPlayers |> List.map (\player -> (player.ign, getColorString Red player.role))
  in
    div [class [GraphContainer]]
    [ div[class [Graph]]
      [ div [class [YAxisLabel]]
        [ text labelName
        ]
      , (plotInteractive
        [ size (512, 512)
        , margin (10, 20, 40, 50)
        , domainLowest (always 0)
        , domainHighest (always highMark)
        , rangeLowest (always <| toFloat start)
        , rangeHighest (always <| toFloat end)
        , style [ ( "position", "relative" ) ]
        ]
        (blueLines ++ redLines ++
        [ xAxis
          [ Axis.line [ stroke "white" ]
          , Axis.label
            [ Label.format (\{ value } -> toString value ++ "s")
            ]
          ]
        , yAxis
          [ Axis.line [ stroke "white" ]
          ]
        , (customHintCreator (blueHintData ++ redHintData)) [] (getHoveredValue model.plotState)
        ])) |> Html.map PlotInteraction
      ]
      , div [ class [GraphControls]]
        [ select
          [ placeholder "Stat"
          , onInput ChangeStat
          ]
          [ option
            [id "XP"]
            [text "XP"]
          , option
            [id "Gold"]
            [text "Gold"]
          , option
            [id "HP"]
            [text "HP"]
          ]
        , div [class [XAxisLabel]]
          [ text "Timestamp"
          ]
      ]
    ]

withinRange : (Float, Float, Float) -> Bool
withinRange (time, start, end) = time >= start && time <= end

getColorString : Side -> Role -> String
getColorString side role =
  case (side, role) of
    (Blue, Top) -> "#b3b3ff"
    (Blue, Jungle) -> "#8080ff"
    (Blue, Mid) -> "#4d4dff"
    (Blue, Bot) -> "#1a1aff"
    (Blue, Support) -> "#0000b3"
    (Red, Top) -> "#ffb3b3"
    (Red, Jungle) -> "#ff8080"
    (Red, Mid) -> "#ff4d4d"
    (Red, Bot) -> "#ff1a1a"
    (Red, Support) -> "#cc0000"

createLineForPlayer: (Timestamp, Timestamp) -> Player -> Side -> GameLength -> (PlayerState -> Float) -> Element msg
createLineForPlayer (start, end) player side gameLength statFunction =
  let
    plotPlayerData: Player -> GameLength -> List(Float, Float)
    plotPlayerData player gameLength =
      uncurry List.range (0, gameLength)
      |> List.filterMap
        (\i ->
          Array.get i player.state
          |> Maybe.map (\state -> (toFloat (i), state))
        )
      |> List.map (Tuple.mapSecond statFunction)
      |> List.filter (\(time,value) -> isNaN value |> not)
      |> List.filter (\(time,value) -> withinRange (time, toFloat start, toFloat end))
  in
  line
    [ stroke <| getColorString side player.role
    , strokeWidth 2
    ]
    (plotPlayerData player gameLength)

getHpPercent : ChampionState -> Float
getHpPercent championState = (100 * championState.hp/championState.hpMax)

getMax : (PlayerState -> Float) -> (Timestamp, Timestamp) -> List Player -> Float
getMax function (start, end) players =
  let
    maxMaybe =
      players
      |> List.map (getMaxOfPlayer function (start, end))
      |> List.maximum
  in
    case maxMaybe of
      Just val -> val
      _ -> 0
getMaxOfPlayer :(PlayerState -> Float) -> (Timestamp, Timestamp) -> Player -> Float
getMaxOfPlayer function (start ,end) player =
  let
    maxMaybe =
      player.state
      |> Array.toList
      |> List.map (\state -> function state)
      |> List.drop start
      |> List.take (end - start)
      |> List.maximum
  in
    case maxMaybe of
      Just val -> val
      _ -> 0

