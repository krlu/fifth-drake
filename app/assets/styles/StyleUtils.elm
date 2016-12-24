module StyleUtils exposing (..)

import Html.Attributes
import Css exposing (Mixin, property)

styles = Css.asPairs >> Html.Attributes.style

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

transition : String -> List Mixin
transition value =
  [ property "transition" value
  , property "-webkit-transition" value
  , property "-o-transition" value
  , property "-moz-transition" value
  ]

visibility : Float -> Mixin
visibility value =
  if value == 0 then
    property "visibility" "hidden"
  else
    property "visibility" "visible"
