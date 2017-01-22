module TeamDisplay.Css exposing (..)

import Css exposing (..)
import Css.Elements exposing (h1, p, span)
import Css.Namespace
import CssColors as Color
import Color
import GameModel exposing (Side(..))
import StyleUtils


namespace =
    "team-display"


teamNameSize : Px
teamNameSize =
    px 48


statsFontSize : Px
statsFontSize =
    px 14


teamDisplayWidth : Px
teamDisplayWidth =
    px 300


teamDisplayHeight : Px
teamDisplayHeight =
    px 125


type CssClass
    = TeamDisplay
    | TeamStats
    | Label


css : Stylesheet
css =
    (stylesheet << Css.Namespace.namespace namespace)
        [ (.) TeamDisplay
            ([ displayFlex
             , alignItems center
             , property "justify-content" "space-around"
             ]
                ++ StyleUtils.flexDirection "column"
                ++ [ width teamDisplayWidth
                   , height teamDisplayHeight
                   , overflow hidden
                   , children
                        [ h1
                            [ fontSize teamNameSize
                            , whiteSpace noWrap
                            ]
                        , (.) TeamStats
                            ([ displayFlex
                             , property "justify-content" "space-around"
                             , width (100 |> pct)
                             ]
                                ++ StyleUtils.flexDirection "row"
                                ++ [ children
                                        [ p
                                            [ color Color.c_offWhite
                                            , flex (int 1)
                                            , textAlign center
                                            , fontSize statsFontSize
                                            , children
                                                [ span
                                                    [ color Color.c_teamStatLabels
                                                    , textTransform uppercase
                                                    ]
                                                ]
                                            ]
                                        ]
                                   ]
                            )
                        ]
                   ]
            )
        ]
