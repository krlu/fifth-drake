module PlayerDisplay.Internal.Plots exposing (..)

import Array
import GameModel exposing (..)
import Maybe exposing (withDefault)
import PlayerDisplay.Css exposing (playerDisplayHeight, playerDisplayWidth)
import Plot exposing (domainHighest, domainLowest, line, margin, plot, size, xAxis)
import Plot.Axis as Axis
import Plot.Line exposing (stroke, strokeWidth)
import Svg
import Tuple

plotData : (Timestamp, Timestamp) -> Player -> Svg.Svg a
plotData range player =
  let
    hp =
      uncurry List.range range
      |> List.filterMap
        (\i ->
          Array.get i player.state
          |> Maybe.map (\state -> (toFloat (i+1), state))
        )
      |> List.map (Tuple.mapSecond (.hp << .championState))
  in
    plot
      [ size (playerDisplayWidth, playerDisplayHeight)
      , margin (10, 20, 40, 20)
      , domainLowest (\val -> val - 10)
      , domainHighest (\val -> val + 10)
      ]
      [ line
        [ stroke "deeppink"
        , strokeWidth 2
        ]
        hp
      , xAxis
        [ Axis.line [ stroke "green" ]
        ]
      ]
