module Timeline.Timeline exposing (init, update, view, subscriptions)

import Html exposing (Html)
import Timeline.Internal.Subscriptions as Subscriptions
import Timeline.Internal.Update as Update
import Timeline.Internal.View as View
import Timeline.Types exposing (..)

initialModel : {a | playButton: String, pauseButton: String} -> Model
initialModel {playButton, pauseButton} =
  { value = 0
  , maxVal = 100
  , mouse = Nothing
  , status = Pause
  , pauseButton = pauseButton
  , playButton = playButton
  }

init : {a | playButton: String, pauseButton: String} -> Model
init = initialModel

update :  Msg -> Model -> (Model, Cmd Msg)
update = Update.update

view : Model -> Html Msg
view = View.view

subscriptions : Model -> Sub Msg
subscriptions = Subscriptions.subscriptions
