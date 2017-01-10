module TagCarousel.Css exposing (..)
import Css.Elements exposing (div)
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
tagCarouselHeight = 100

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
  | PlayerCheckboxes
  | CheckboxCss
  | DeleteButtonCss
  | SelectedTag
  | TagDisplay
  | MinimizedCarousel
  | AltTag
  | TagFormTextInput
  | TagFormTextBox
  | TagFormTextArea
  | PlayersInvolved
  | AddTagButton
  | SaveOrCancelForm

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) TagCarousel (
    [ width (tagCarouselWidth |> pct)
    , displayFlex
    , height (tagCarouselHeight |> pct)
    , backgroundColor Color.c_carousel
    , float left
    , overflowX scroll
    , flexDirection row
    , flexWrap noWrap
    ] ++
    StyleUtils.userSelect "none")
  , (.) TagFormCss (
      [ width (44 |> pct)
      , height (100 |> pct)
      , overflowY auto
      , backgroundColor Color.c_darkGray
      , float left
      , position relative
      , displayFlex
      , flexWrap wrap
      ] ++ StyleUtils.userSelect "none"
    )
  , (#) PlayerCheckboxes(
      [ width (40 |> pct)
      , height (75 |> pct)
      ]
    )
  , (#) CheckboxCss(
      [ margin (66 |> px)
      ]
    )
  , (.) MinimizedCarousel(
      [ width (minimizedCarouselWidth |> pct)
      ])
  , (#) TagDisplay
    [ property "float" "left"
    , width (100 |> pct)
    , height (210 |> px)
    , marginTop (30 |> px)
    , displayFlex
    ]
  , (#) TagFormTextInput
    [ displayFlex
    , flexWrap wrap
    , width (60 |> pct)
    , height (90 |> pct)
    ]
  , (#) TagFormTextBox
    [ width (49.2 |> pct)
    , height (15 |> pct)
    ]
  , (#) TagFormTextArea
    [ width (99 |> pct)
    , height (85 |> pct)
    ]
  , (#) PlayersInvolved
    [ fontSize (18 |> px)
    , backgroundColor Color.c_lightGray
    , height (15 |> pct)
    ]
  , (#) AddTagButton
    [ height (100 |> pct)
    , width (16 |> pct)
    , backgroundColor Color.c_carousel
    , hover [backgroundColor Color.c_hovering]
    ]
  , (#) SaveOrCancelForm
    [ position absolute
    , bottom (0 |> px)
    ]
  , (.) Tag
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
    , hover
      [ backgroundColor Color.c_hovering
      , children
        [ (.) DeleteButtonCss
          [ position absolute
          , bottom zero
          , hover
            [ backgroundColor Color.c_darkGray
            , display block
            ]
          , displayFlex
          ]
        ]
      ]
    ]
  , (.) AltTag
    [ width (altTagWidth |> pct)
    ]
  , (.) SelectedTag
    [ backgroundColor Color.c_selected
    , hover
      [ backgroundColor Color.c_selected
      ]
    ]
  , (.) DeleteButtonCss
    [ display none
    ]
  ]
