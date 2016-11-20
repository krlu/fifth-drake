module Timeline.Timeline exposing (init, update, view, subscriptions)

import Html exposing (Html)
import Timeline.Internal.ModelUtils as ModelUtils
import Timeline.Internal.Subscriptions as Subscriptions
import Timeline.Internal.Update as Update
import Timeline.Internal.View as View
import Timeline.Internal.Populate as Populate
import Timeline.Types exposing (..)
import Types exposing (WindowLocation)

init : {a | playButton: String, pauseButton: String, location: WindowLocation} -> (Model, Cmd Msg)
init flags = (ModelUtils.initialModel flags, Populate.populate flags.location)

update :  Msg -> Model -> (Model, Cmd Msg)
update = Update.update

view : Model -> Html Msg
view = View.view

subscriptions : Model -> Sub Msg
subscriptions = Subscriptions.subscriptions
