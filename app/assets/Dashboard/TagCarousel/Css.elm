module TagCarousel.Css exposing (..)
import Css.Colors exposing (black)
import Css.Elements exposing (div, img)
import CssColors as Color
import Css exposing (..)
import Css.Namespace
import Minimap.Css
import StyleUtils
import List

namespace : String
namespace = "tagCarousel"

tagDisplayWidth : Float
tagDisplayWidth = 100 -- percent

tagDisplayHeight : Float
tagDisplayHeight = 170

addTagButtonHeight : Float
addTagButtonHeight = 50 -- px

addTagButtonWidth : Float
addTagButtonWidth = 16 -- percent

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

tagFormWidth : Float
tagFormWidth = 44 -- percent

tagFormHeight : Float
tagFormHeight = 100 -- percent

playerCheckBoxesWidth : Float
playerCheckBoxesWidth = 66 -- px

playerCheckBoxesHeight : Float
playerCheckBoxesHeight = 100 -- percent

checkboxMargin : Float
checkboxMargin = 68

playersInvolvedFontSize : Float
playersInvolvedFontSize = 18

playersInvolvedHeight : Float
playersInvolvedHeight = 15 -- percent

tagFormTextInputWidth : Float
tagFormTextInputWidth = 75 -- pct

tagFormTextInputHeight : Float
tagFormTextInputHeight = 96.5 -- percent

tagFormTextBoxWidth : Float
tagFormTextBoxWidth = 100-- percent

tagFormTextBoxHeight : Float
tagFormTextBoxHeight = 15 -- percent

tagFormTextAreaWidth : Float
tagFormTextAreaWidth = 100 -- percent

tagFormTextAreaHeight : Float
tagFormTextAreaHeight = 70 -- percent

saveOrCancelFormDistFromBottom : Float
saveOrCancelFormDistFromBottom = 0

tagBorderSize : Float
tagBorderSize = 1

tagMargin : Float
tagMargin = 10

tagOptionBorderRadius : Float
tagOptionBorderRadius = 1 -- vh

labelImageSize : Float
labelImageSize = 20 -- px

carouselControlHeight : Float
carouselControlHeight = 39 -- px

carouselControlWidth : Float
carouselControlWidth = 100 -- px

carouselControlBorderRadius : Float
carouselControlBorderRadius = 10 -- px

carouselControlBorderWidth : Float
carouselControlBorderWidth = 1 --px

shareTagFontSize: Float
shareTagFontSize = 18 -- px

carouselContainerHeight : Float
carouselContainerHeight = 211 -- px

type CssClass
  = TagCarousel
  | TagCss
  | TagFormCss
  | PlayerCheckboxes
  | CheckboxLabel
  | TagOptionsCss
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
  | PlusImage
  | CheckboxItem
  | LabelImage
  | TagClickableArea
  | ShareTagCss
  | CarouselContainer
  | HighlightSharedTag
  | UnsharedTag
  | CarouselControls
  | FilterTagCss
  | SelectedFilter
  | UnselectedFilter
  | CarouselControlCss

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ id TagDisplay
    [ property "float" "left"
    , width (tagDisplayWidth |> pct)
    , height (tagDisplayHeight |> px)
    , displayFlex
    , children
      [ id AddTagButton
        [ height (addTagButtonHeight |> px)
        , width (addTagButtonHeight |> px)
        , borderRadius (50 |> pct)
        , backgroundColor Color.c_carousel
        , hover
          [ backgroundColor Color.c_hovering
          , cursor pointer
          ]
        , children
          [ class PlusImage
              [ width (100 |> pct)
              ]
          ]
        ]
      , class TagFormCss (
        [ width (tagFormWidth |> pct)
        , height (tagFormHeight |> pct)
        , overflowY auto
        , backgroundColor Color.c_darkGray
        , float left
        , position relative
        , displayFlex
        , flexWrap wrap
        , children
          [ class PlayerCheckboxes
            [ width (playerCheckBoxesWidth |> px)
            , height (playerCheckBoxesHeight |> pct)
            , displayFlex
            , flexWrap wrap
            , children
              [ class CheckboxItem
                [ flexDirection column
                , children
                  [ class CheckboxLabel
                    [ children
                      [ (img)
                        [ float left
                        ]
                      ]
                    ]
                  , class PlayersInvolved
                    [ fontSize (playersInvolvedFontSize |> px)
                    , backgroundColor Color.c_lightGray
                    , height (playersInvolvedHeight |> pct)
                    , float left
                    ]
                  ]
                ]
              ]
            ]
          , id TagFormTextInput
            [ displayFlex
            , flexWrap wrap
            , width auto
            , height (tagFormTextInputHeight |> pct)
            , children
              [ class TagFormTextBox
                [ width (tagFormTextBoxWidth |> pct)
                , height (tagFormTextBoxHeight |> pct)
                , flexDirection column
                ]
              , class TagFormTextArea
                [ width (tagFormTextAreaWidth |> pct)
                , height (tagFormTextAreaHeight |> pct)
                , flexDirection column
              ]
              ]
            ]
          , id SaveOrCancelForm
            [ position absolute
            , bottom (saveOrCancelFormDistFromBottom |> px)
            ]
          ]
        ] ++ StyleUtils.userSelect "none" )
      , class TagCarousel (
        [ width (tagCarouselWidth |> pct)
        , displayFlex
        , height (tagCarouselHeight |> pct)
        , backgroundColor Color.c_carousel
        , float left
        , overflowX scroll
        , flexDirection row
        , flexWrap noWrap
        , children
          [ class TagCss
            [ height (tagHeight |> pct)
            , width (tagWidth |> pct)
            , backgroundColor Color.c_navBar
            , border2 (tagBorderSize |> px) solid
            , border2 (tagBorderSize |> px) solid
            , color Color.c_blackText
            , float left
            , listStyleType none
            , property "align-content" "center"
            , margin (tagMargin |> px)
            , flexShrink zero
            , position relative
            , hover
              [ backgroundColor Color.c_hovering
              , cursor pointer
              , children
                [ class TagOptionsCss
                  [ position absolute
                  , bottom zero
                  , hover
                    [ backgroundColor Color.c_tag_option
                    ]
                  , displayFlex
                  , borderRadius (tagOptionBorderRadius |> vh)
                  ]
                ]
              ]
            , children
              [ class TagOptionsCss
                [ display none
                ]
              ]
            ]
          , class SelectedTag
            [ backgroundColor Color.c_selected
            , hover
              [ backgroundColor Color.c_selected
              ]
            ]
          , class HighlightSharedTag
            [ backgroundColor Color.c_shared_tag
            , hover [backgroundColor Color.c_shared_tag]
            ]
          , class UnsharedTag
            [ backgroundColor Color.c_unshared_tag
            , hover [backgroundColor Color.c_unshared_tag]
            ]
          ]
        ] ++ StyleUtils.userSelect "none")
      , class MinimizedCarousel
        [ width (minimizedCarouselWidth |> pct)
        , children
          [ class AltTag
            [ width (altTagWidth |> pct)
            ]
          ]
        ]
      ]
    ]
  , class LabelImage
    [ height (labelImageSize |> px)
    , width (labelImageSize |> px)
    ]
  , class TagClickableArea
    [ height (100 |> pct)
    , width (100 |> pct)
    , overflow hidden
    ]
  , class CarouselControlCss
    [ height (carouselControlHeight |> px)
    , width (carouselControlWidth |> px)
    , property "border-width" ((toString carouselControlBorderWidth ) ++ "px")
    , borderStyle groove
    , borderBottomStyle none
    , borderColor (rgb 0 0 0)
    ]
  , class ShareTagCss
    [ backgroundColor Color.c_share_tag_button
    , lineHeight (carouselControlHeight |> px)
    , textAlign center
    , borderRadius (carouselControlBorderRadius |> px)
    , fontSize (shareTagFontSize |> px)
    , hover
      [ backgroundColor Color.c_share_tag_button_hover
      , cursor pointer
      ]
    ]
  , class FilterTagCss
    [ lineHeight (carouselControlHeight |> px)
    , textAlign center
    , borderRadius4 (carouselControlBorderRadius |> px) (carouselControlBorderRadius |> px) (0 |> px) (0 |> px)
    , fontSize (shareTagFontSize |> px)
    , hover [ cursor pointer ]
    ]
  , class SelectedFilter
      [ backgroundColor Color.c_filter_tag_selected
      ]
  , class UnselectedFilter
    [ backgroundColor Color.c_filter_tag
    ]
  , class CarouselContainer
    [ width (100 |> pct)
    , height (carouselContainerHeight |> px)
    ]
  , class CarouselControls
    [ displayFlex
    ]
  ]

