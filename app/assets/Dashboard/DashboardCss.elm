module DashboardCss exposing (..)

import Css exposing (..)
import Css.Namespace
import CssColors as Color
import Minimap.Css exposing (minimapHeight, minimapWidth)
import StyleUtils
import TagScroller.Css exposing (tagScrollerWidth)
import TeamDisplay.Css exposing (teamDisplayWidth)

namespace : String
namespace = "dashboard"

dividerWidth : Float
dividerWidth = 10

teamDisplaysGap : Float
teamDisplaysGap = 50

teamDisplaysWidth : Float
teamDisplaysWidth = teamDisplayWidth * 2 + teamDisplaysGap

type CssId
  = TeamDisplayDivider
  | ControlsDivider

type CssClass
  = Dashboard
  | TeamDisplays

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) Dashboard (
    [ displayFlex
    , alignItems center
    ] ++ StyleUtils.flexDirection "column" ++
    [ children
      [ (.) TeamDisplays (
        [ displayFlex
        , width (teamDisplaysWidth |> px)
        , property "justify-content" "space-between"
        ] ++ StyleUtils.flexDirection "row")
      ]
    ])
  , (#) TeamDisplayDivider
    [ width auto
    , height (30 |> px)
    ]
  , (#) ControlsDivider
    [ width auto
    , height (50 |> px)
    ]
  ]
