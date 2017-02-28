module Graph.Css exposing (..)

import Css exposing (..)
import Css.Elements exposing (h1, p, span)
import Css.Namespace
import CssColors as Color exposing (c_slateGrey)
import Color
import GameModel exposing (Side(..))
import StyleUtils

namespace : String
namespace = "graph"

graphHeight : Float
graphHeight = 512

graphWidth : Float
graphWidth = 512

xAxisLabelLeft : Float
xAxisLabelLeft = 37 -- Percent

yAxisLabelWidth : Float
yAxisLabelWidth = 100

yAxisLabelTop : Float
yAxisLabelTop = 20

type CssClass
  = Graph
  | DisplayCategories
  | GraphControls
  | XAxisLabel
  | GraphContainer
  | YAxisLabel
  | HintCss

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) GraphContainer(
    [ width (100 |> pct)
    , height (100 |> pct)
    ]
    )
  , (.) Graph (
    [ displayFlex
    , alignItems center
    , height (graphHeight |> px)
    , width (graphWidth |> px)
    , property "justify-content" "space-around"
    ] ++ StyleUtils.userSelect "none")
  , (.)GraphControls(
    [ displayFlex
    , width (100 |> pct)
    ])
  , (.) XAxisLabel(
    [ position relative
    , left (xAxisLabelLeft |> pct)
    , color c_slateGrey
    ] )
  , (.) YAxisLabel(
    [ position relative
    , color c_slateGrey
    , top (yAxisLabelTop |> px)
    ] )
  , (.) HintCss(
    [ property "color" "#4d4dff"
    ])
  ]
