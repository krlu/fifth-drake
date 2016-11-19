module NavbarCss exposing(..)

import Css exposing (..)
import Css.Elements exposing (a, span)
import Css.Namespace

namespace : String
namespace = "navbar"

primaryColor : Color
primaryColor = hex "#B59FE8"

secondaryColor : Color
secondaryColor = hex "#2883FF"

collapsedWidth : Float
collapsedWidth = 3

expandedWidth : Float
expandedWidth = 15

type CssClass
  = NavbarLeft
  | Collapsed
  | Expanded
  | Collapsible

type CssIds
  = NavbarLinks
  | NavbarLeftLogo

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) NavbarLeft
    [ fontSize (24 |> px)
    , backgroundColor primaryColor
    , color (hex "#FFFFFF")
    , position fixed
    , height (100 |> pct)
    , padding (5 |> px)
    , overflow hidden
    , property "-webkit-user-select" "none"
    , property "user-select" "none"
    , withClass Collapsed
      [ width (collapsedWidth |> vw)
      , property "transition" "width 0.5s ease-in-out"
      ]
    , withClass Expanded
      [ width (expandedWidth |> vw)
      , property "transition" "width 0.5s ease-in-out"
      ]
    , children
      [ (#) NavbarLeftLogo
        [ textAlign center
        , padding (10 |> px)
        , marginTop (20 |> px)
        , marginBottom (20 |> px)
        , hover
          [ cursor pointer
          ]
        ]
      , (#) NavbarLinks
        [ textAlign center
        , children
          [ a
            [ padding (5 |> px)
            , property "display" "table"
            , hover
              [ color secondaryColor
              , cursor pointer
              ]
            , children
              [ span
                [ property "display" "table-cell"
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  , (.) Collapsible
    [ textAlign right
    , padding (5 |> px)
    , color secondaryColor
    , hover
      [ color (hex "#FFFFFF")
      , cursor pointer
      ]
    ]
  ]