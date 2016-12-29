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
tagCarouselWidth = 84 -- percent

minimizedCarouselWidth : Float
minimizedCarouselWidth = 56 -- percent

tagCarouselHeight : Float
tagCarouselHeight = 211

tagHeight : Float
tagHeight = 80 -- percent

tagWidth : Float
tagWidth = 20 -- percent

altTagWidth : Float
altTagWidth = 30 -- percent

tagFormHeight : Float
tagFormHeight = 100

type CssClass
  = TagCarousel
  | Tag
  | TagFormCss
  | CheckboxCss
  | DeleteButtonCss
  | SelectedTag
  | TagDisplay
  | MinimizedCarousel
  | AltTag
  | AltSelectedTag

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
      [ width (44 |> pct)
      , height (211 |> px)
      , overflowY auto
      , backgroundColor Color.c_darkGray
      , float left
      , position relative
      ] ++ StyleUtils.userSelect "none"
    )
  , (.) CheckboxCss(
      [
      ]
    )
  , (.) DeleteButtonCss(
      [ position absolute
      , bottom zero
      ]
    )
  , (.) MinimizedCarousel(
      [ width (minimizedCarouselWidth |> pct)
      , displayFlex
      , height (tagCarouselHeight |> px)
      , backgroundColor Color.c_carousel
      , float left
      , overflowX scroll
      , flexDirection row
      , flexWrap noWrap
      ]++
      StyleUtils.userSelect "none" ++
      [ children
        [ (.) AltTag
         [ height (tagHeight |> pct)
         , width (altTagWidth |> pct)
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
         (.) AltSelectedTag
         [ height (tagHeight |> pct)
         , width (altTagWidth |> pct)
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
      ]
    )
  , (#) TagDisplay
    [ property "float" "left"
    , width (100 |> pct)
    , height (211 |> px)
    , paddingTop (30 |> px)
    ]
  ]
