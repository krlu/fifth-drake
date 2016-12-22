module Controls.Controls exposing (init, update, view, subscriptions)

import Controls.Internal.Subscriptions as Subscriptions
import Controls.Internal.Update as Update
import Controls.Internal.View as View
import Controls.Types exposing (..)
import GameModel exposing (GameLength)
import Html exposing (Html)
import Types exposing (TimeSelection)

initialModel : String -> String -> Model
initialModel playButton pauseButton =
  { mouse = Nothing
  , status = Pause
  , pauseButton = pauseButton
  , playButton = playButton
  }

init : String -> String -> Model
init = initialModel

update : TimeSelection -> GameLength -> Msg -> Model -> (TimeSelection, Model)
update = Update.update

view : TimeSelection -> GameLength -> Model -> Html Msg
view = View.view

subscriptions : Model -> Sub Msg
subscriptions = Subscriptions.subscriptions
