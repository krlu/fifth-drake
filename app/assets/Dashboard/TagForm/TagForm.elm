module TagForm.TagForm exposing (..)

import Html exposing (Html)
import TagForm.Types exposing(..)
import TagForm.Internal.View as View
import TagForm.Internal.Update as Update

init : (Model, Cmd Msg)
init = (Model "" "" "" "" "", Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update = Update.update

view : Html Msg
view = View.view

subscriptions : Sub Msg
subscriptions = Sub.none
