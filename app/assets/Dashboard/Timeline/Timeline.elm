module Timeline.Timeline exposing (init, update, view, subscriptions)

import Html exposing (Html)
import Timeline.Internal.ModelUtils as ModelUtils
import Timeline.Internal.Subscriptions as Subscriptions
import Timeline.Internal.Update as Update
import Timeline.Internal.View as View
import Timeline.Types exposing (..)

init : {a | playButton: String, pauseButton: String} -> (Model, Cmd Msg)
init flags = (ModelUtils.initialModel flags, Cmd.none)

update :  Msg -> Model -> (Model, Cmd Msg)
update = Update.update

view : Model -> Html Msg
view = View.view

subscriptions : Model -> Sub Msg
subscriptions = Subscriptions.subscriptions
