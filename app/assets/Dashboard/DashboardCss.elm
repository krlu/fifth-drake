module DashboardCss exposing (..)

import Css exposing (..)
import Css.Namespace
import CssColors as Color
import GameModel exposing (Side(Blue, Red))
import Minimap.Css exposing (minimapHeight, minimapWidth)
import StyleUtils
import TagCarousel.Css exposing (tagCarouselWidth)
import TeamDisplay.Css exposing (teamDisplayContainerWidth)

namespace : String
namespace = "dashboard"

teamDisplaysGap : Float
teamDisplaysGap = 50

teamDisplaysWidth : Float
teamDisplaysWidth = teamDisplayContainerWidth * 2 + teamDisplaysGap

contentGap : Float
contentGap = 40

controlsGap : Float
controlsGap = 2

teamDisplayGap : Float
teamDisplayGap = 30

playerDisplaysGap : Float
playerDisplaysGap = 20

teamDisplayMarginLeft : Float
teamDisplayMarginLeft = 11.7 --vw

mainContentMarginLeft : Float
mainContentMarginLeft = 2 --vw

switchBorderRadius : Float
switchBorderRadius = 8  -- px

switchWidth : Float
switchWidth = 9 -- vw

switchHeight : Float
switchHeight = 3 -- vh

switchFontSize : Float
switchFontSize = 2 -- vh

type CssId
  = TeamDisplayDivider
  | ControlsDivider
  | MainContent
  | CenterContent
  | CarouselDivider
  | LoadingCss

type CssClass
  = Dashboard
  | TeamDisplays
  | PlayerDisplay
  | Widget
  | WidgetColor Side
  | SwitchCss
  | LoadingCenterContent

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
          , class LoadingCenterContent
            [ height (574 |> px)
            , width (85 |> vw)
            ]
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
    , backgroundColor Color.c_share_tag_button
    , hover
      [ backgroundColor Color.c_share_tag_button_hover
      , cursor pointer
      ]
    , borderRadius (switchBorderRadius |> px)
    , width (switchWidth |> vw)
    , height (switchHeight |> vh)
    , textAlign center
    , lineHeight (switchHeight |> vh)
    , fontSize (switchFontSize |> vh)
    ]
  , id LoadingCss
    [ position relative
    , top (8 |> vh)
    ]
  ]
