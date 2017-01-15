module NavbarCss exposing (..)

import Css exposing (..)
import Css.Elements exposing (a, span)
import Css.Namespace
import CssColors as Color
import StyleUtils


namespace : String
namespace =
    "navbar"


navbarWidth : Float
navbarWidth =
    50


buttonHeight : Float
buttonHeight =
    50


type CssClass
    = NavbarLeft
    | Selected


type CssIds
    = NavbarLinks
    | NavbarLeftLogo


css : Stylesheet
css =
    (stylesheet << Css.Namespace.namespace namespace)
        [ (.) NavbarLeft
            ([ backgroundColor Color.c_navBar
             , height (100 |> pct)
             , width (navbarWidth |> px)
             ]
                ++ StyleUtils.userSelect "none"
                ++ [ children
                        [ (#) NavbarLeftLogo
                            [ displayFlex
                            , alignItems center
                            , property "justify-content" "center"
                            , height (buttonHeight |> px)
                            , hover
                                [ cursor pointer
                                ]
                            , children
                                [ a
                                    [ textDecoration none
                                    , fontSize (30 |> px)
                                    , color Color.c_gold
                                    ]
                                ]
                            ]
                        , (#) NavbarLinks
                            ([ displayFlex
                             ]
                                ++ StyleUtils.flexDirection "column"
                                ++ [ property "justify-content" "center"
                                   , width (navbarWidth |> px)
                                   , height (100 |> pct)
                                   , children
                                        [ a
                                            [ displayFlex
                                            , alignItems center
                                            , property "justify-content" "center"
                                            , height (buttonHeight |> px)
                                            , hover
                                                [ color Color.c_navBarSelected
                                                , cursor pointer
                                                ]
                                            , children
                                                [ span
                                                    [ property "display" "table-cell"
                                                    ]
                                                ]
                                            ]
                                        , (.) Selected
                                            [ backgroundColor Color.c_navBarSelected
                                            ]
                                        ]
                                   ]
                            )
                        ]
                   ]
            )
        ]
