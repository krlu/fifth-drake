module TagCarousel.Css exposing (..)
import CssColors as Color
import Css exposing (..)
import Css.Namespace
import Minimap.Css
import StyleUtils

namespace : String
namespace = "tagCarousel"

tagCarouselWidth : Float
tagCarouselWidth = 1250

tagCarouselHeight : Float
tagCarouselHeight = 100

tagHeight : Float
tagHeight = 60

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
    , backgroundColor Color.c_carousel
    ] ++
    StyleUtils.userSelect "none" ++
    [ children
      [ (.) Tag
        [ height (tagHeight |> px)
        , width auto
        , backgroundColor Color.c_navBar
        , border2 (1 |> px) solid
        , property "align-content" "right"
        ]
      ]
    ])
  ]
