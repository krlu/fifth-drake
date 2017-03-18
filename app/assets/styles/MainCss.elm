module MainCss exposing (..)

import Css exposing (..)
import Css.Elements exposing (..)
import Css.Namespace
import CssColors as Color
import StyleUtils

namespace : String
namespace = "main"

type CssId
  = Container
  | Navbar
  | Content

css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ everything
    [ margin zero
    , padding zero
    , fontFamilies ["Rubik", "sans-serif"]
    , fontWeight (300 |> int)
    ]
  , body
    [ fontSize Css.small
    , overflow hidden
    ]
  , id Container (
    [ displayFlex
    , backgroundColor Color.c_backgroundDark
    ] ++ StyleUtils.flexDirection "row" ++
    [ alignItems stretch
    , flexWrap noWrap
    , children
      [ id Navbar
        [ order (1 |> int)
        , flex (0 |> int)
        , height (100 |> vh)
        ]
      , id Content
        [ order (2 |> int)
        , flex (1 |> int)
        , height (100 |> vh)
        , displayFlex
        , justifyContent center
        ]
      ]
    ])
  ]
