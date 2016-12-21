module TagCarousel.Css exposing (..)
import CssColors as Color
import Css exposing (..)
import Css.Namespace
import Minimap.Css
import StyleUtils
import List

namespace : String
namespace = "tagCarousel"

tagCarouselWidth : Float
tagCarouselWidth = 1250

tagCarouselHeight : Float
tagCarouselHeight = 100

tagHeight : Float
tagHeight = 60

tagFormHeight : Float
tagFormHeight = 100

type CssClass
  = TagCarousel
  | Tag
  | TagFormCss

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) TagCarousel (
    [ width (80 |> pct)
    , height (tagCarouselHeight |> px)
    , overflowY auto
    , backgroundColor Color.c_carousel
    , property "float" "left"
    ] ++
    StyleUtils.userSelect "none" ++
    [ children
      [ (.) Tag
        [ height (tagHeight |> px)
        , width auto
        , backgroundColor Color.c_navBar
        , border2 (1 |> px) solid
        , property "align-content" "center"
        , property "float" "left"
        , property "list-style-type" "none"
        , margin (10 |> px)
        ]
      ]
    ])
  , (.) TagFormCss (
       [ width (160 |> px)
       , height (250 |> px)
       , overflowY auto
       , backgroundColor Color.c_darkGray
       , property "float" "left"
       ] ++ StyleUtils.userSelect "none")
  ]
