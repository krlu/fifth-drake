module StyleUtils exposing (..)

import Html.Attributes
import Css exposing (Mixin, property)


styles =
    Css.asPairs >> Html.Attributes.style


userSelect : String -> List Mixin
userSelect value =
    [ property "user-select" value
    , property "-webkit-touch-callout" value
    , property "-webkit-user-select" value
    , property "-khtml-user-select" value
    , property "-moz-user-select" value
    , property "-ms-user-select" value
    ]


flexDirection : String -> List Mixin
flexDirection direction =
    [ property "flex-direction" direction
    , property "-ms-flex-direction" direction
    , property "-webkit-flex-direction" direction
    ]
