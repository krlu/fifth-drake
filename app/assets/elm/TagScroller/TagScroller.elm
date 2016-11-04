module TagScroller.TagScroller exposing (init, update, view, subscriptions)

import Html exposing (Html)
import TagScroller.Types exposing (..)
import TagScroller.Internal.Populate as Populate
import TagScroller.Internal.Update as Update
import TagScroller.Internal.View as View

init : (Model, Cmd Msg)
init = ({ tags = [] }, Populate.populate)

update : Msg -> Model -> (Model, Cmd Msg)
update = Update.update

view : Model -> Html Msg
view = View.view

subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none

