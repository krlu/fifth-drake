module Subscriptions exposing (..)

import Minimap.Minimap as Minimap
import TagScroller.TagScroller as TagScroller
import Timeline.Timeline as Timeline
import Types exposing (..)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map MinimapMsg <| Minimap.subscriptions model.minimap
    , Sub.map TagScrollerMsg <| TagScroller.subscriptions model.tagScroller
    , Sub.map TimelineMsg <| Timeline.subscriptions model.timeline
    ]
