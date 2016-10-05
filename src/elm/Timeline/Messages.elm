module Timeline.Messages exposing (..)

import Mouse
import Time

type Msg
  = KnobGrab Mouse.Position
  | KnobMove Mouse.Position
  | KnobRelease Mouse.Position
  | BarClick Mouse.Position
  | PlayPause
  | TimerUpdate Time.Time
