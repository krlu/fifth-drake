module NavbarCss exposing(..)

import Css exposing (..)
import Css.Elements exposing (a, span)
import Css.Namespace
import CssColors as Color
import StyleUtils

namespace : String
namespace = "navbar"

navbarWidth : Float
navbarWidth = 50

buttonHeight : Float
buttonHeight = 50

type CssClass
  = NavbarLeft
  | Selected
  | ToolTip

type CssIds
  = NavbarLinks
  | NavbarLeftLogo

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ class NavbarLeft (
    [ backgroundColor Color.c_navBar
    , height (100 |> pct)
    , width (navbarWidth |> px)
    ] ++ StyleUtils.userSelect "none" ++
    [ children
      [ id NavbarLeftLogo
        [ displayFlex
        , alignItems center
        , justifyContent center
        , height (buttonHeight |> px)
        , hover
          [ cursor pointer
          ]
        , children
          [ a
            [ textDecoration none
            , fontSize (30 |> px)
            , color Color.c_gold
            ]
          ]
        ]
      , id NavbarLinks (
        [ displayFlex
        ] ++ StyleUtils.flexDirection "column" ++
        [ justifyContent center
        , width (navbarWidth |> px)
        , height (100 |> pct)
        , children
          [ a
            [ displayFlex
            , alignItems center
            , justifyContent center
            , height (buttonHeight |> px)
            , hover
              [ color Color.c_navBarSelected
              , cursor pointer
              ]
            , children
              [ span
                [ display tableCell
                ]
              ]
            ]
          , class Selected
            [ backgroundColor Color.c_navBarSelected
            ]
          ]
        ])
      ]
    ])
  , class ToolTip
    [ backgroundColor Color.c_tool_tip_background
    , width (98 |> px)
    , color Color.c_slateGrey
    , position absolute
    , left (47 |> px)
    , fontSize (14 |> px)
    , textAlign center
    , borderRadius (6 |> px)
    ]
  ]
