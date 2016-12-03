module Timeline.Timeline exposing (init, update, view, subscriptions)

import GameModel exposing (GameLength, Timestamp)
import Html exposing (Html)
import Timeline.Internal.Subscriptions as Subscriptions
import Timeline.Internal.Update as Update
import Timeline.Internal.View as View
import Timeline.Types exposing (..)

initialModel : {a | playButton: String, pauseButton: String} -> Model
initialModel {playButton, pauseButton} =
  { mouse = Nothing
  , status = Pause
  , pauseButton = pauseButton
  , playButton = playButton
  }

init : {a | playButton: String, pauseButton: String} -> Model
init = initialModel

update : Timestamp -> GameLength -> Msg -> Model -> (Timestamp, Model)
update = Update.update

view : Timestamp -> GameLength -> Model -> Html Msg
view = View.view

subscriptions : Model -> Sub Msg
subscriptions = Subscriptions.subscriptions
