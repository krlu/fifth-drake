module Graph.Graph exposing (..)

import Array
import Css exposing (height, pct, width, zero)
import GameModel exposing (..)
import Graph.Types exposing (Model, Msg(ChangeStat), Stat(Gold, HP, XP))
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
import StyleUtils exposing (styles)
import Tuple

{id, class, classList} = withNamespace namespace

init : Model
init =
  { selectedStat = XP
  }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ChangeStat stat ->
      case stat of
        "XP" -> ( {model | selectedStat = XP}, Cmd.none)
        "Gold" -> ( {model | selectedStat = Gold}, Cmd.none)
        "HP" -> ({model | selectedStat = HP}, Cmd.none)
        _ ->  (model, Cmd.none)


view : Model -> Game -> Set PlayerId -> Html Msg
view model game selectedPlayers =
  let
    (statFunction, highMark, labelName) =
      case model.selectedStat of
        HP -> (getHpPercent << .championState, 100, "HP%")
        Gold -> (.totalGold, 30000, "Total Gold")
        XP -> (.xp << .championState, 30000, "Total XP")
    bluePlayers =  Array.toList game.data.blueTeam.players
    redPlayers = Array.toList game.data.redTeam.players
    blueLines = List.map (\player -> createLineForPlayer player Blue game.metadata.gameLength statFunction)
                  <| List.filter (\player -> Set.member player.id selectedPlayers) bluePlayers
    redLines = List.map (\player -> createLineForPlayer player Red game.metadata.gameLength statFunction)
                  <| List.filter (\player -> Set.member player.id selectedPlayers) redPlayers
  in
    div [class [GraphContainer]]
    [ div[class [Graph]]
      [ div [class [YAxisLabel]]
        [ text labelName
        ]
      , plot
        [ size (512, 512)
        , margin (10, 20, 40, 50)
        , domainLowest (always 0)
        , domainHighest (always highMark)
        , rangeLowest (always 0)
        , rangeHighest (always <| toFloat game.metadata.gameLength)
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
        , hint [] Nothing
        ])
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

getColorString: Side -> Role -> String
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

createLineForPlayer: Player -> Side -> GameLength -> (PlayerState -> Float) -> Element msg
createLineForPlayer player side gameLength statFunction =
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
  in
  line
    [ stroke <| getColorString side player.role
    , strokeWidth 2
    ]
    (plotPlayerData player gameLength)

getHpPercent : ChampionState -> Float
getHpPercent championState = (100 * championState.hp/championState.hpMax)
