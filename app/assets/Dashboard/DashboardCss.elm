module DashboardCss exposing (..)

import Css exposing (..)
import Css.Namespace
import Minimap.Css exposing (minimapHeight, minimapWidth)
import StyleUtils
import TagScroller.Css exposing (tagScrollerWidth)

namespace : String
namespace = "dashboard"

dividerWidth : Float
dividerWidth = 10

type CssClass
  = MapAndTags
  | Vdivider
  | Hdivider
  | Dashboard

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) Dashboard
    [ width (minimapWidth + dividerWidth + tagScrollerWidth |> px)
    , margin2 (30 |> px) auto
    , children
      [ (.) MapAndTags (
        [ width auto
        , height (minimapHeight |> px)
        , displayFlex
        , textAlign center
        ] ++
        StyleUtils.flexDirection "row")
      ]
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
