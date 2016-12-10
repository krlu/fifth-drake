module TagCarousel.Css exposing (..)

import Css exposing (..)
import Css.Namespace
import Minimap.Css
import StyleUtils

namespace : String
namespace = "tagCarousel"

tagCarouselWidth : Float
tagCarouselWidth = 60

tagCarouselHeight : Float
tagCarouselHeight = Minimap.Css.minimapHeight

tagHeight : Float
tagHeight = 100

type CssClass
  = TagCarousel
  | Tag

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) TagCarousel (
    [ width (tagCarouselWidth |> px)
    , height (tagCarouselHeight |> px)
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
