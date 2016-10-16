module Messages exposing (..)

import Minimap.Messages as MMsg
import Timeline.Messages as TMsg
import TagScroller.Messages as TagMsg

type Msg
  = TimelineMsg TMsg.Msg
  | MinimapMsg MMsg.Msg
  | TagScrollerMsg TagMsg.Msg
