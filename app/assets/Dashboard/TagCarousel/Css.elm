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
    , displayFlex
    , height (tagCarouselHeight |> px)
    , backgroundColor Color.c_carousel
    , float left
    , overflowX scroll
    , flexDirection row
    , flexWrap noWrap
    ] ++
    StyleUtils.userSelect "none" ++
    [ children
      [ (.) Tag
        [ height (tagHeight |> px)
        , width (tagWidth |> px)
        , backgroundColor Color.c_navBar
        , border2 (1 |> px) solid
        , float left
        , listStyleType none
        , property "align-content" "center"
        , margin (10 |> px)
        , flexShrink zero
        ]
      ]
    ])
  , (.) TagFormCss (
       [ width (15 |> pct)
       , height (140 |> px)
       , overflowY auto
       , backgroundColor Color.c_darkGray
       , float left
       ] ++ StyleUtils.userSelect "none")
  , (.) CheckboxCss(
       [ margin (20 |> px)
       ]
    )
  ]
