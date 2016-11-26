module TagForm.TagForm exposing (..)

import Html exposing (Html)
import TagForm.Types exposing(..)
import TagForm.Internal.View as View
import TagForm.Internal.Update as Update

init: Model -> (Model, Cmd Msg)
init form = (form, Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update = Update.update

view : Model -> Html Msg
view = View.view

subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none
