module Graph.Graph exposing (..)

import Array
import Css exposing (height, pct, width, zero)
import GameModel exposing (..)
import Html exposing (..)
import Html.Attributes exposing (draggable, src)
import Html.CssHelpers exposing (withNamespace)
import Graph.Css exposing (CssClass(..), namespace)
import PlayerDisplay.Internal.Plots exposing (getHpPercent)
import Plot exposing (..)
import Plot.Line exposing (stroke, strokeWidth)
import Plot.Axis as Axis
import Set exposing (Set)
import String
import StyleUtils exposing (styles)
import Tuple

{id, class, classList} = withNamespace namespace



view : Game -> Set PlayerId -> Html a
view game selectedPlayers =
  let
    bluePlayers =  Array.toList game.data.blueTeam.players
    redPlayers = Array.toList game.data.redTeam.players
    blueLines = List.map (\player -> createLineForPlayer player Blue game.metadata.gameLength)
                  <| List.filter (\player -> Set.member player.id selectedPlayers) bluePlayers
    redLines = List.map (\player -> createLineForPlayer player Red game.metadata.gameLength)
                  <| List.filter (\player -> Set.member player.id selectedPlayers) redPlayers
  in
    div[class [Graph]]
      [
        plot
        [ size (512, 512)
        , margin (10, 20, 40, 50)
        , domainLowest (always 0)
        , domainHighest (always 30000)
        ]
        (blueLines ++ redLines ++
        [ xAxis
          [ Axis.line [ stroke "white" ]
          ]
        , yAxis
          [ Axis.line [ stroke "white" ]
          ]
        ])
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

createLineForPlayer: Player -> Side -> Int -> Element msg
createLineForPlayer player side gameLength=
  line
    [ stroke <| getColorString side player.role
    , strokeWidth 2
    ]
    (plotPlayerXp player gameLength)

plotPlayerXp: Player -> GameLength -> List(Float, Float)
plotPlayerXp player gameLength =
  uncurry List.range (0, gameLength)
  |> List.filterMap
    (\i ->
      Array.get i player.state
      |> Maybe.map (\state -> (toFloat (i), state))
    )
  |> List.map (Tuple.mapSecond (.xp << .championState))
