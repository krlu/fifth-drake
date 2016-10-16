module Timeline.Messages exposing (..)

import Mouse
import Time
import Timeline.Models exposing (Value)

type Msg
  = KnobGrab Mouse.Position
  | KnobMove Mouse.Position
  | KnobRelease Mouse.Position
  | BarClick Mouse.Position
  | PlayPause
  | TimerUpdate Time.Time
  | SetValue Value
