module MainCss exposing (..)

import Css exposing (..)
import Css.Elements exposing (..)
import Css.Namespace
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
    ]
  , body
    [ fontSize Css.small
    ]
  , (#) Container (
    [ displayFlex
    ] ++ StyleUtils.flexDirection "row" ++
    [ alignItems stretch
    , flexWrap noWrap
    , children
      [ (#) Navbar
        [ order (1 |> int)
        , flexGrow (0 |> int)
        , height (100 |> vh)
        ]
      , (#) Content
        [ order (2 |> int)
        , flexGrow (1 |> int)
        , height (100 |> vh)
        ]
      ]
    ])
  ]
