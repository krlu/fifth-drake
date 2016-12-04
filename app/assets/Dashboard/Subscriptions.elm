module Subscriptions exposing (..)

import Controls.Controls as Controls
import TagScroller.TagScroller as TagScroller
import Types exposing (..)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map TagScrollerMsg <| TagScroller.subscriptions model.tagScroller
    , Sub.map ControlsMsg <| Controls.subscriptions model.controls
    ]
