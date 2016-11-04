module Timeline.Types exposing (..)

import Mouse
import Time

type Msg
  = KnobGrab Mouse.Position
  | KnobMove Mouse.Position
  | KnobRelease Mouse.Position
  | BarClick Mouse.Position
  | PlayPause
  | TimerUpdate Time.Time
  | SetValue Value

type alias Value = Int
type alias File = String

type alias Model =
  { value: Value
  , maxVal: Value
  , mouse: Maybe Drag

  , status: Status
  , width: Float

  , pauseButton: File
  , playButton: File
  }

type alias Drag =
  { start: Mouse.Position
  , current: Mouse.Position
  }

type Status
  = Play
  | Pause

