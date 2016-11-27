module DashboardCss exposing (..)

import Css exposing (..)
import Css.Namespace
import CssColors as Color
import Minimap.Css exposing (minimapHeight, minimapWidth)
import StyleUtils
import TagScroller.Css exposing (tagScrollerWidth)

namespace : String
namespace = "dashboard"

dividerWidth : Float
dividerWidth = 10

type CssClass
  = Vdivider
  | Hdivider
  | Dashboard

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) Dashboard
    [ width (minimapWidth |> px)
    , margin2 (30 |> px) auto
    ]
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
