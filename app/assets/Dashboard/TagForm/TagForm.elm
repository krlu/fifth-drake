module TagForm.TagForm exposing (..)

import Html exposing (Html)
import TagForm.Types exposing(..)
import TagForm.Internal.View as View
import TagForm.Internal.Update as Update
import Timeline.Types as Types
import Types exposing (WindowLocation)

init : WindowLocation -> (Model, Cmd Msg)
init loc = (Model "" "" "" 0 "" loc.gameId loc.host, Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update = Update.update

view : Model -> Html Msg
view = View.view

subscriptions : Sub Msg
subscriptions = Sub.none
