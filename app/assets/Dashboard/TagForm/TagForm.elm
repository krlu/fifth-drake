module TagForm.TagForm exposing (..)

import Html exposing (Html)
import TagForm.Types exposing(..)
import TagForm.Internal.View as View

view : Html Msg
view = View.view

subscriptions : Sub Msg
subscriptions = Sub.none
