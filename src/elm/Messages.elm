module Messages exposing (..)

import Minimap.Messages as MMsg
import Timeline.Messages as TMsg

type Msg
  = TimelineMsg TMsg.Msg
  | MinimapMsg MMsg.Msg
