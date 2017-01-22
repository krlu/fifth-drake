module Controls.Css exposing (..)

import Css exposing (..)
import Css.Namespace
import CssColors as Color
import DashboardCss
import StyleUtils


-- Variables for Timeline appearance
-- All of these values are pixel equivalents


namespace =
    "controls"


controlsWidth : Px
controlsWidth =
    px 512


controlsHeight : Px
controlsHeight =
    px 60


buttonWidth : Px
buttonWidth =
    controlsHeight


timelineWidth : Px
timelineWidth =
    px (controlsWidth.numericValue - buttonWidth.numericValue)


barHeight : Px
barHeight =
    px 7


knobHeight : Px
knobHeight =
    px 12


knobWidth : Px
knobWidth =
    px 1


knobBottom : Px
knobBottom =
    px <| (controlsHeight.numericValue - barHeight.numericValue) / 2


type CssClass
    = Bar
    | BarSeen
    | Controls
    | Hidden
    | Knob
    | PlayButton
    | PlayPauseImg
    | TimeDisplay
    | Timeline
    | TimelineAndDisplay


css : Stylesheet
css =
    (stylesheet << Css.Namespace.namespace namespace)
        [ (.) Controls
            ([ displayFlex
             , height controlsHeight
             , width controlsWidth
             ]
                ++ StyleUtils.flexDirection "row"
                ++ StyleUtils.userSelect "none"
                ++ [ alignItems center
                   , children
                        [ (.) TimelineAndDisplay
                            ([ displayFlex
                             , position relative
                             , height (100 |> pct)
                             ]
                                ++ StyleUtils.flexDirection "column"
                                ++ [ property "justify-content" "space-between"
                                   , alignItems flexEnd
                                   , children
                                        [ (.) Timeline
                                            [ position relative
                                            , height barHeight
                                            , width timelineWidth
                                            , backgroundColor Color.c_lightGray
                                            , textAlign right
                                            , children
                                                [ (.) BarSeen
                                                    [ property "pointer-events" "none"
                                                    , backgroundColor Color.c_darkerGray
                                                    , height (100 |> pct)
                                                    ]
                                                ]
                                            ]
                                        , (.) TimeDisplay
                                            [ color Color.c_white
                                            , withClass Hidden
                                                [ property "visibility" "hidden"
                                                ]
                                            ]
                                        , (.) Knob
                                            [ position absolute
                                            , bottom knobBottom
                                            , left zero
                                            , width knobWidth
                                            , height knobHeight
                                            , backgroundColor Color.c_darkerGray
                                            , transform << translateX << pct <| -50
                                            ]
                                        ]
                                   ]
                            )
                        , (.) PlayButton
                            [ height (100 |> pct)
                            , property "border" "none"
                            , property "background" "none"
                            , padding zero
                            , width buttonWidth
                            , children
                                [ (.) PlayPauseImg
                                    [ height (100 |> pct)
                                    , width (100 |> pct)
                                    ]
                                ]
                            ]
                        ]
                   ]
            )
        ]
