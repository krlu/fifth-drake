module Minimap.Css exposing (..)

import Css exposing (..)
import Css.Namespace
import StyleUtils


namespace : String
namespace =
    "minimap"


minimapHeight : Px
minimapHeight =
    px 512


minimapWidth : Px
minimapWidth =
    px 512


playerIconSize : Px
playerIconSize =
    px 30


type CssClass
    = Minimap
    | PlayerIcon
    | Background
    | ChampionImage


css : Stylesheet
css =
    (stylesheet << Css.Namespace.namespace namespace)
        [ (.) Minimap
            ([ position relative
             , height minimapHeight
             , width minimapWidth
             ]
                ++ StyleUtils.userSelect "none"
                ++ [ children
                        [ (.) PlayerIcon
                            [ position absolute
                            , width playerIconSize
                            , height playerIconSize
                            , transform <| translate2 (-50 |> pct) (50 |> pct)
                            , children
                                [ (.) ChampionImage
                                    [ width (100 |> pct)
                                    , height (100 |> pct)
                                    , borderRadius (50 |> pct)
                                    ]
                                ]
                            ]
                        , (.) Background
                            [ height (100 |> pct)
                            , width (100 |> pct)
                            ]
                        ]
                   ]
            )
        ]
