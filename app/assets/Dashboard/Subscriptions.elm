module Subscriptions exposing (..)

import Controls.Controls as Controls
import Minimap.Minimap as Minimap exposing (..)
import TagCarousel.TagCarousel as TagCarousel
import Types exposing (..)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map ControlsMsg <| Controls.subscriptions model.controls
    , Sub.map MinimapMsg <| Minimap.subscriptions model.minimap
    ]
