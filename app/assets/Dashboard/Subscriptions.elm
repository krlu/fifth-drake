module Subscriptions exposing (..)

import Controls.Controls as Controls
import Controls.Types as ControlsT
import Configuration exposing (animationTime)
import Minimap.Minimap as Minimap exposing (..)
import PlaybackTypes exposing (..)
import TagCarousel.TagCarousel as TagCarousel
import Time
import Types exposing (..)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map ControlsMsg <| Controls.subscriptions model.controls
    , Sub.map MinimapMsg <| Minimap.subscriptions model.minimap
    , case model.controls.status of
        Pause -> Sub.none
        Play -> Time.every animationTime TimerUpdate
    ]
