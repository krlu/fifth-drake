module Messages exposing (..)

import Timeline.Messages as TMsg
import Minimap.Messages as MMsg

type Msg
  = TimelineMsg TMsg.Msg
  | MinimapMsg MMsg.Msg
