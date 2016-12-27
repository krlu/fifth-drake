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
tagCarouselWidth = 85 -- percent

tagCarouselHeight : Float
tagCarouselHeight = 211

tagHeight : Float
tagHeight = 80 -- percent

tagWidth : Float
tagWidth = 20 -- percent

tagFormHeight : Float
tagFormHeight = 100

type CssClass
  = TagCarousel
  | Tag
  | TagFormCss
  | CheckboxCss
  | DeleteButtonCss
  | SelectedTag

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) TagCarousel (
    [ width (tagCarouselWidth |> pct)
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
        [ height (tagHeight |> pct)
        , width (tagWidth |> pct)
        , backgroundColor Color.c_navBar
        , border2 (1 |> px) solid
        , color Color.c_blackText
        , float left
        , listStyleType none
        , property "align-content" "center"
        , margin (10 |> px)
        , flexShrink zero
        , position relative
        ],
        (.) SelectedTag
        [ height (tagHeight |> pct)
        , width (tagWidth |> pct)
        , backgroundColor Color.c_selectedTag
        , border2 (1 |> px) solid
        , color Color.c_blackText
        , float left
        , listStyleType none
        , property "align-content" "center"
        , margin (10 |> px)
        , flexShrink zero
        , position relative
        ]
      ]
    ])
  , (.) TagFormCss (
       [ width (15 |> pct)
       , height (211 |> px)
       , overflowY auto
       , backgroundColor Color.c_darkGray
       , float left
       ] ++ StyleUtils.userSelect "none")
  , (.) CheckboxCss(
       [
       ]
    )
  , (.) DeleteButtonCss(
       [ position absolute
       , bottom zero
       ]
    )
  ]
