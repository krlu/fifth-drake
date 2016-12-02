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
  | TeamDisplays

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) Dashboard (
    [ displayFlex
    , property "align-items" "center"
    ] ++ StyleUtils.flexDirection "column" ++
    [ children
      [ (.) TeamDisplays (
        [ displayFlex
        ] ++ StyleUtils.flexDirection "row")
      ]
    ])
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
