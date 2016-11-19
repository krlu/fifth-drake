module DashboardCss exposing (..)

import Css exposing (..)
import Css.Namespace
import Minimap.Css exposing (minimapHeight, minimapWidth)
import StyleUtils
import TagScroller.Css exposing (tagScrollerWidth)

namespace : String
namespace = "content"

dividerWidth : Float
dividerWidth = 10

type CssClasses
  = Content
  | Vdivider
  | Hdivider

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) Content (
    [ width (minimapWidth + dividerWidth + tagScrollerWidth |> px)
    , height (minimapHeight |> px)
    , displayFlex
    ] ++
    StyleUtils.flexDirection "row")
  , (.) Vdivider (
    [ height (100 |> pct)
    , width (dividerWidth |> px)
    ] ++
    StyleUtils.userSelect "none")
  , (.) Hdivider (
    [ height (dividerWidth |> px)
    , width (100 |> pct)
    ] ++
    StyleUtils.userSelect "none")
  ]
