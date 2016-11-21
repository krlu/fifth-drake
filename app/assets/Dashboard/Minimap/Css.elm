module Minimap.Css exposing (..)

import Css exposing (..)
import Css.Namespace
import StyleUtils

namespace : String
namespace = "minimap"

minimapHeight : Float
minimapHeight = 512

minimapWidth : Float
minimapWidth = 512

playerIconSize : Float
playerIconSize = 30

type CssClass
  = Minimap
  | PlayerIcon
  | Background

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) Minimap (
    [ position relative
    , height (minimapHeight |> px)
    , width (minimapWidth |> px)
    ] ++
    StyleUtils.userSelect "none" ++
    [ children
      [ (.) PlayerIcon
        [ position absolute
        , width (playerIconSize |> px)
        , height (playerIconSize |> px)
        , backgroundColor (hex "#A52A2A")
        , borderRadius (50 |> pct)
        , transform <| translate2 (-50 |> pct) (50 |> pct)
        ]
      , (.) Background
        [ height (100 |> pct)
        , width (100 |> pct)
        ]
      ]
    ])
  ]