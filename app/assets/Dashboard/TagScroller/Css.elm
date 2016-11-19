module TagScroller.Css exposing (..)

import Css exposing (..)
import Css.Namespace
import Minimap.Css
import StyleUtils

namespace : String
namespace = "tagscroller"

tagScrollerWidth : Float
tagScrollerWidth = 200

tagScrollerHeight : Float
tagScrollerHeight = Minimap.Css.minimapHeight

tagHeight : Float
tagHeight = 100

type CssClasses
  = TagScroller
  | Tag

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) TagScroller (
    [ width (tagScrollerWidth |> px)
    , height (tagScrollerHeight |> px)
    , overflowY auto
    , backgroundColor (hex "#D2691E")
    ] ++
    StyleUtils.userSelect "none" ++
    [ children
      [ (.) Tag
        [ height (tagHeight |> px)
        , width auto
        , backgroundColor (hex "#7FFFD4")
        , border2 (1 |> px) solid
        , property "align-content" "center"
        ]
      ]
    ])
  ]
