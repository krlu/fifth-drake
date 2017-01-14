module PlayerDisplay.Internal.Plots exposing (..)

import Array
import GameModel exposing (..)
import PlayerDisplay.Css exposing (playerDisplayHeight, playerDisplayWidth)
import Plot exposing (Point, line, margin, plot, size, xAxis)
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
    Debug.log ""
    plot
      [ size (playerDisplayWidth, playerDisplayHeight)
      , margin (10, 20, 40, 20)
      ]
      [ line
        [ stroke "deeppink"
        , strokeWidth 2
        ]
        (Debug.log "hp:" hp)
      , xAxis
        [ Axis.line [ stroke "green" ]
        ]
      ]