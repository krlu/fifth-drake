module TagCarousel.Css exposing (..)
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
tagDisplayHeight = 210

tagDisplayMarginTop : Float
tagDisplayMarginTop = 30

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
playerCheckBoxesWidth = 64 -- px

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
tagFormTextInputHeight = 100 -- percent

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

labelImageSize : Float
labelImageSize = 20 -- px

type CssClass
  = TagCarousel
  | Tag
  | TagFormCss
  | PlayerCheckboxes
  | CheckboxLabel
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
  | PlusImage
  | CheckboxItem
  | LabelImage

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (#) TagDisplay
    [ property "float" "left"
    , width (tagDisplayWidth |> pct)
    , height (tagDisplayHeight |> px)
    , marginTop (tagDisplayMarginTop |> px)
    , displayFlex
    , children
      [ (#) AddTagButton
        [ height (addTagButtonHeight |> px)
        , width (addTagButtonHeight |> px)
        , borderRadius (50 |> pct)
        , backgroundColor Color.c_carousel
        , hover [backgroundColor Color.c_hovering]
        , children
          [ (.) PlusImage
              [ width (100 |> pct)
              ]
          ]
        ]
      , (.) TagFormCss (
        [ width (tagFormWidth |> pct)
        , height (tagFormHeight |> pct)
        , overflowY auto
        , backgroundColor Color.c_darkGray
        , float left
        , position relative
        , displayFlex
        , flexWrap wrap
        , children
          [ (.) PlayerCheckboxes
            [ width (playerCheckBoxesWidth |> px)
            , height (playerCheckBoxesHeight |> pct)
            , displayFlex
            , flexWrap wrap
            , children
              [ (.) CheckboxItem
                [ flexDirection column
                , children
                  [ (.) CheckboxLabel
                    [ children
                      [ (img)
                        [ float left
                        ]
                      ]
                    ]
                  , (.) PlayersInvolved
                    [ fontSize (playersInvolvedFontSize |> px)
                    , backgroundColor Color.c_lightGray
                    , height (playersInvolvedHeight |> pct)
                    , float left
                    ]
                  ]
                ]
              ]
            ]
          , (#) TagFormTextInput
            [ displayFlex
            , flexWrap wrap
            , width auto
            , height (tagFormTextInputHeight |> pct)
            , children
              [ (.) TagFormTextBox
                [ width (tagFormTextBoxWidth |> pct)
                , height (tagFormTextBoxHeight |> pct)
                , flexDirection column
                ]
              , (.) TagFormTextArea
                [ width (tagFormTextAreaWidth |> pct)
                , height (tagFormTextAreaHeight |> pct)
                , flexDirection column
              ]
              ]
            ]
          , (#) SaveOrCancelForm
            [ position absolute
            , bottom (saveOrCancelFormDistFromBottom |> px)
            ]
          ]
        ] ++ StyleUtils.userSelect "none" )
      , (.) TagCarousel (
        [ width (tagCarouselWidth |> pct)
        , displayFlex
        , height (tagCarouselHeight |> pct)
        , backgroundColor Color.c_carousel
        , float left
        , overflowX scroll
        , flexDirection row
        , flexWrap noWrap
        , children
          [ (.) Tag
            [ height (tagHeight |> pct)
            , width (tagWidth |> pct)
            , backgroundColor Color.c_navBar
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
              , children
                [ (.) DeleteButtonCss
                  [ position absolute
                  , bottom zero
                  , hover
                    [ backgroundColor Color.c_darkGray
                    ]
                  , displayFlex
                  ]
                ]
              ]
            , children
              [ (.) DeleteButtonCss
                [ display none
                ]
              ]
            ]
          , (.) SelectedTag
            [ backgroundColor Color.c_selected
            , hover
              [ backgroundColor Color.c_selected
              ]
            ]
          ]
        ] ++ StyleUtils.userSelect "none")
      , (.) MinimizedCarousel
        [ width (minimizedCarouselWidth |> pct)
        , children
          [ (.) AltTag
            [ width (altTagWidth |> pct)
            ]
          ]
        ]
      ]
    ]
  , (.) LabelImage
    [ height (labelImageSize |> px)
    , width (labelImageSize |> px)
    ]
  ]
