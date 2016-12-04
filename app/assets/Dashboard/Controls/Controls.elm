module Controls.Controls exposing (init, update, view, subscriptions)

import Controls.Internal.Subscriptions as Subscriptions
import Controls.Internal.Update as Update
import Controls.Internal.View as View
import Controls.Types exposing (..)
import GameModel exposing (GameLength, Timestamp)
import Html exposing (Html)

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
