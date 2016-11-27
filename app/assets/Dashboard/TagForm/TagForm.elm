module TagForm.TagForm exposing (..)

import Html exposing (Html)
import TagForm.Types exposing(..)
import TagForm.Internal.View as View
import TagForm.Internal.Update as Update
import Timeline.Types as Types

init : (Model, Cmd Msg)
init = (Model "" "" "" 0 "", Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update = Update.update

view : Model -> Html Msg
view = View.view

subscriptions : Sub Msg
subscriptions = Sub.none
