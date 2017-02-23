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
import String
import StyleUtils exposing (styles)
import Tuple

{id, class, classList} = withNamespace namespace

view : Game -> Html a
view game =
  let
    bluePlayer1 =  Array.get 0 game.data.blueTeam.players
    redPlayer1 = Array.get 0 game.data.redTeam.players
    blue = case bluePlayer1 of
      Nothing -> []
      Just player ->
          plotPlayerXp player game.metadata.gameLength
    red = case redPlayer1 of
      Nothing -> []
      Just player ->
          plotPlayerXp player game.metadata.gameLength
  in
    div[class [Graph]]
      [
        plot
        [ size (512, 512)
        , margin (10, 20, 40, 20)
        , domainLowest (always 0)
        , domainHighest (always 30000)
        ]
        [ line
          [ stroke "blue"
          , strokeWidth 2
          ]
          blue
        , line
          [ stroke "red"
          , strokeWidth 2
          ]
          red
        , xAxis
          [ Axis.line [ stroke "white" ]
          ]
        ]
      ]

plotPlayerXp: Player -> GameLength -> List(Float, Float)
plotPlayerXp player gameLength =
  uncurry List.range (60, gameLength)
  |> List.filterMap
    (\i ->
      Array.get i player.state
      |> Maybe.map (\state -> (toFloat (i), state))
    )
  |> List.map (Tuple.mapSecond (.xp << .championState))
