module Graph.Css exposing (..)

import Css exposing (..)
import Css.Elements exposing (h1, p, span)
import Css.Namespace
import CssColors as Color
import Color
import GameModel exposing (Side(..))
import StyleUtils

namespace : String
namespace = "graph"

graphHeight : Float
graphHeight = 512

graphWidth : Float
graphWidth = 512

type CssClass
  = Graph
  | DisplayCategories

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) Graph (
    [ displayFlex
    , alignItems center
    , height (graphHeight |> px)
    , width (graphWidth |> px)
    , property "justify-content" "space-around"
    ] ++ StyleUtils.userSelect "none")
  ]
