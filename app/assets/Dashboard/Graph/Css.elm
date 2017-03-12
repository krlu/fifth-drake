module Graph.Css exposing (..)

import Css exposing (..)
import Css.Elements exposing (h1, p, span)
import Css.Namespace
import CssColors as Color exposing (c_lightYellow, c_slateGrey)
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
xAxisLabelLeft = 48 -- Percent

yAxisLabelWidth : Float
yAxisLabelWidth = 100

yAxisLabelTop : Float
yAxisLabelTop = 20

opacityValue : Float
opacityValue = 0.2

graphControlMarginTop : Float
graphControlMarginTop = 32

graphControlLeft : Float
graphControlLeft = 90

hintFontSize : Float
hintFontSize = 18

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
    , position relative
    , marginTop (graphControlMarginTop |> px )
    , left (graphControlLeft |> px)
    ])
  , (.) XAxisLabel(
    [ position relative
    , left (xAxisLabelLeft |> pct)
    , color c_slateGrey
    , width (100 |> px)
    , height (10 |> px)
    , left (48 |> pct)
    ] )
  , (.) YAxisLabel(
    [ position relative
    , color c_slateGrey
    , top (yAxisLabelTop |> px)
    ] )
  , (.) HintCss(
    [ backgroundColor c_lightYellow
    , opacity (opacityValue |> num)
    , fontSize (hintFontSize |> px)
    ])
  ]
