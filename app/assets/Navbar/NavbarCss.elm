module NavbarCss exposing (..)

import Css exposing (..)
import Css.Elements exposing (a, span)
import Css.Namespace
import CssColors as Color
import StyleUtils


namespace : String
namespace =
    "navbar"


navbarWidth : Px
navbarWidth =
    px 50


buttonHeight : Px
buttonHeight =
    px 50


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
             , width navbarWidth
             ]
                ++ StyleUtils.userSelect "none"
                ++ [ children
                        [ (#) NavbarLeftLogo
                            [ displayFlex
                            , alignItems center
                            , property "justify-content" "center"
                            , height buttonHeight
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
                                   , width navbarWidth
                                   , height (100 |> pct)
                                   , children
                                        [ a
                                            [ displayFlex
                                            , alignItems center
                                            , property "justify-content" "center"
                                            , height buttonHeight
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
