module DashboardCss exposing (..)

import Css exposing (..)
import Css.Namespace
import CssColors as Color
import GameModel exposing (Side(Blue, Red))
import Minimap.Css exposing (minimapHeight, minimapWidth)
import StyleUtils
import TagCarousel.Css exposing (tagCarouselWidth)
import TeamDisplay.Css exposing (teamDisplayWidth)

namespace : String
namespace = "dashboard"

teamDisplaysGap : Float
teamDisplaysGap = 50

teamDisplaysWidth : Float
teamDisplaysWidth = teamDisplayWidth * 2 + teamDisplaysGap

contentGap : Float
contentGap = 40

controlsGap : Float
controlsGap = 20

teamDisplayGap : Float
teamDisplayGap = 30

playerDisplaysGap : Float
playerDisplaysGap = 20

type CssId
  = TeamDisplayDivider
  | ControlsDivider
  | MainContent
  | CenterContent
  | CarouselDivider

type CssClass
  = Dashboard
  | TeamDisplays
  | PlayerDisplay
  | Widget
  | WidgetColor Side
  | SwitchCss

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) Dashboard (
    [ width (100 |> pct)
    , displayFlex
    , alignItems center
    ] ++ StyleUtils.flexDirection "column" ++
    [ children
      [ (.) TeamDisplays (
        [ displayFlex
        , width (teamDisplaysWidth |> px)
        , property "justify-content" "space-between"
        , marginBottom (teamDisplayGap |> px)
        ] ++ StyleUtils.flexDirection "row")
      , (#) MainContent (
        [ displayFlex
        , property "justify-content" "flex-start"
        ] ++ StyleUtils.flexDirection "row" ++
        [ children
          [ (#) CenterContent (
            [ displayFlex
            , alignItems center
            , marginLeft (contentGap |> px)
            , marginRight (contentGap |> px)
            ] ++ StyleUtils.flexDirection "column" ++
            [ children
              [ everything
                [ firstChild
                  [ marginBottom (controlsGap |> px)
                  ]
                ]
              ]
            ])
          , (.) PlayerDisplay (
            [ displayFlex
            , property "justify-content" "flex-start"
            ] ++ StyleUtils.flexDirection "column" ++
            [ children
              [ everything
                [ marginTop (playerDisplaysGap |> px)
                , firstChild
                  [ marginTop zero
                  ]
                ]
              ]
            ])
          ]
        ]
        )
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
  , (.) Widget
    [ display inlineBlock
    , backgroundColor (hex "#3b4047")
    , borderBottom2 (3 |> px) solid
    , borderBottomLeftRadius (3 |> px)
    , borderBottomRightRadius (3 |> px)
    , withClass (WidgetColor Blue)
      [ color Color.c_blueTeam
      , borderColor Color.c_blueTeam
      ]
    , withClass (WidgetColor Red)
      [ color Color.c_redTeam
      , borderColor Color.c_redTeam
      ]
    ]
  , (.) SwitchCss
    [ position relative
    , right (40 |> pct)
    , top (10 |> pct)
    ]
  ]
