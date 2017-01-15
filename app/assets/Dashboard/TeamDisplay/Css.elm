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


teamNameSize : Float
teamNameSize =
    48


statsFontSize : Float
statsFontSize =
    14


teamDisplayWidth : Float
teamDisplayWidth =
    300


teamDisplayHeight : Float
teamDisplayHeight =
    125


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
                ++ [ width (teamDisplayWidth |> px)
                   , height (teamDisplayHeight |> px)
                   , overflow hidden
                   , children
                        [ h1
                            [ fontSize (teamNameSize |> px)
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
                                            , fontSize (statsFontSize |> px)
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
