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
tagCarouselHeight = 140

tagHeight : Float
tagHeight = 80

tagWidth : Float
tagWidth = 80

tagFormHeight : Float
tagFormHeight = 100

type CssClass
  = TagCarousel
  | Tag
  | TagFormCss
  | CheckboxCss

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) TagCarousel (
    [ width (85 |> pct)
    , height (tagCarouselHeight |> px)
    , overflowY auto
    , backgroundColor Color.c_carousel
    , property "float" "left"
    , overflowX scroll
    ] ++
    StyleUtils.userSelect "none" ++
    [ children
      [ (.) Tag
        [ height (tagHeight |> px)
        , width (tagWidth |> px)
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
       [ width (15 |> pct)
       , height (140 |> px)
       , overflowY auto
       , backgroundColor Color.c_darkGray
       , property "float" "left"
       ] ++ StyleUtils.userSelect "none")
  , (.) CheckboxCss(
       [ margin (20 |> px)
       ]
    )
  ]
