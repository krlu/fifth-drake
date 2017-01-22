module TagCarousel.Css exposing (..)

import Css.Elements exposing (div)
import CssColors as Color
import Css exposing (..)
import Css.Namespace
import Minimap.Css
import StyleUtils
import List


namespace : String
namespace =
    "tagCarousel"


tagDisplayHeight : Px
tagDisplayHeight =
    px 210


tagDisplayMarginTop : Px
tagDisplayMarginTop =
    px 30


addTagButtonWidth : Pct
addTagButtonWidth =
    pct 16


tagCarouselWidth : Pct
tagCarouselWidth =
    pct 84


minimizedCarouselWidth : Pct
minimizedCarouselWidth =
    pct 56


tagHeight : Pct
tagHeight =
    pct 80


tagWidth : Pct
tagWidth =
    pct 20


altTagWidth : Pct
altTagWidth =
    pct 30


tagFormWidth : Pct
tagFormWidth =
    pct 44


playerCheckBoxesWidth : Pct
playerCheckBoxesWidth =
    pct 40


playerCheckBoxesHeight : Pct
playerCheckBoxesHeight =
    pct 75


checkboxMargin : Px
checkboxMargin =
    px 68


playersInvolvedFontSize : Px
playersInvolvedFontSize =
    px 18


playersInvolvedHeight : Pct
playersInvolvedHeight =
    pct 15


tagFormTextInputWidth : Pct
tagFormTextInputWidth =
    pct 60


tagFormTextInputHeight : Pct
tagFormTextInputHeight =
    pct 90


tagFormTextBoxWidth : Pct
tagFormTextBoxWidth =
    pct 49.2


tagFormTextBoxHeight : Pct
tagFormTextBoxHeight =
    pct 15


tagFormTextAreaWidth : Pct
tagFormTextAreaWidth =
    pct 99


tagFormTextAreaHeight : Pct
tagFormTextAreaHeight =
    pct 85


tagBorderSize : Px
tagBorderSize =
    px 1


tagMargin : Px
tagMargin =
    px 10


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
        [ (#) TagDisplay
            [ property "float" "left"
            , width (100 |> pct)
            , height tagDisplayHeight
            , marginTop tagDisplayMarginTop
            , displayFlex
            , children
                [ (#) AddTagButton
                    [ height (100 |> pct)
                    , width addTagButtonWidth
                    , backgroundColor Color.c_carousel
                    , hover [ backgroundColor Color.c_hovering ]
                    ]
                , (.) TagFormCss
                    ([ width tagFormWidth
                     , height (100 |> pct)
                     , overflowY auto
                     , backgroundColor Color.c_darkGray
                     , float left
                     , position relative
                     , displayFlex
                     , flexWrap wrap
                     , children
                        [ (#) PlayerCheckboxes
                            [ width playerCheckBoxesWidth
                            , height playerCheckBoxesHeight
                            , children
                                [ (#) CheckboxCss
                                    [ margin checkboxMargin
                                    ]
                                , (#) PlayersInvolved
                                    [ fontSize playersInvolvedFontSize
                                    , backgroundColor Color.c_lightGray
                                    , height playersInvolvedHeight
                                    ]
                                ]
                            ]
                        , (#) TagFormTextInput
                            [ displayFlex
                            , flexWrap wrap
                            , width tagFormTextInputWidth
                            , height tagFormTextInputHeight
                            , children
                                [ (#) TagFormTextBox
                                    [ width tagFormTextBoxWidth
                                    , height tagFormTextBoxHeight
                                    ]
                                , (#) TagFormTextArea
                                    [ width tagFormTextAreaWidth
                                    , height tagFormTextAreaHeight
                                    ]
                                ]
                            ]
                        , (#) SaveOrCancelForm
                            [ position absolute
                            , bottom zero
                            ]
                        ]
                     ]
                        ++ StyleUtils.userSelect "none"
                    )
                , (.) TagCarousel
                    ([ width tagCarouselWidth
                     , displayFlex
                     , height (100 |> pct)
                     , backgroundColor Color.c_carousel
                     , float left
                     , overflowX scroll
                     , flexDirection row
                     , flexWrap noWrap
                     , children
                        [ (.) Tag
                            [ height tagHeight
                            , width tagWidth
                            , backgroundColor Color.c_navBar
                            , border2 tagBorderSize solid
                            , color Color.c_blackText
                            , float left
                            , listStyleType none
                            , property "align-content" "center"
                            , margin tagMargin
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
                     ]
                        ++ StyleUtils.userSelect "none"
                    )
                , (.) MinimizedCarousel
                    [ width minimizedCarouselWidth
                    , children
                        [ (.) AltTag
                            [ width altTagWidth
                            ]
                        ]
                    ]
                ]
            ]
        ]
