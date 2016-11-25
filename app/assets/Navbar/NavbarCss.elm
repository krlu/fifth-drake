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

type CssClass
  = NavbarLeft

type CssIds
  = NavbarLinks
  | NavbarLeftLogo

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) NavbarLeft (
    [ backgroundColor Color.c_navBar
    , color Color.c_gold
    , height (100 |> pct)
    , width (navbarWidth |> px)
    ] ++ StyleUtils.userSelect "none" ++
    [ children
      [ (#) NavbarLeftLogo
        [ textAlign center
        , hover
          [ cursor pointer
          ]
        ]
      , (#) NavbarLinks (
        [ displayFlex
        ] ++ StyleUtils.flexDirection "column" ++
        [ property "justify-content" "center"
        , width (navbarWidth |> px)
        , height (100 |> pct)
        , children
          [ a
            [ padding (5 |> px)
            , margin2 zero auto
            , property "display" "table"
            , hover
              [ color Color.c_navBarSelected
              , cursor pointer
              ]
            , children
              [ span
                [ property "display" "table-cell"
                ]
              ]
            ]
          ]
        ])
      ]
    ])
  ]