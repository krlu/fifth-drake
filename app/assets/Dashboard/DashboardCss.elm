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
controlsGap = 2

teamDisplayGap : Float
teamDisplayGap = 30

playerDisplaysGap : Float
playerDisplaysGap = 20

teamDisplayMarginLeft : Float
teamDisplayMarginLeft = 24.5 --vw

mainContentMarginLeft : Float
mainContentMarginLeft = 2 --vw

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
  [ class Dashboard (
    [ width (100 |> pct)
    , property "display" "block"
    , alignItems center
    ] ++ StyleUtils.flexDirection "column" ++
    [ children
      [ class TeamDisplays (
        [ displayFlex
        , width (teamDisplaysWidth |> px)
        , justifyContent spaceBetween
        , marginBottom (teamDisplayGap |> px)
        , marginLeft (teamDisplayMarginLeft|> vw)
        ] ++ StyleUtils.flexDirection "row")
      , id MainContent (
        [ displayFlex
        , justifyContent flexStart
        , marginLeft (mainContentMarginLeft |> vw)
        ] ++ StyleUtils.flexDirection "row" ++
        [ children
          [ id CenterContent (
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
          , class PlayerDisplay (
            [ displayFlex
            , justifyContent flexStart
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
  , id TeamDisplayDivider
    [ width auto
    , height (30 |> px)
    ]
  , id ControlsDivider
    [ width auto
    , height (50 |> px)
    ]
  , class Widget
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
  , class SwitchCss
    [ position absolute
    ]
  ]
