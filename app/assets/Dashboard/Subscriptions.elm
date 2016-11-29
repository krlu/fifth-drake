module Subscriptions exposing (..)

import TagScroller.TagScroller as TagScroller
import Timeline.Timeline as Timeline
import Types exposing (..)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map TagScrollerMsg <| TagScroller.subscriptions model.tagScroller
    , Sub.map TimelineMsg <| Timeline.subscriptions model.timeline
    ]
