module Controls.Types exposing (..)

import Mouse
import Time
import Http


type Msg
  = KnobGrab Mouse.Position
  | KnobMove Mouse.Position
  | KnobRelease Mouse.Position
  | BarClick (Mouse.Position, Mouse.Position)
  | PlayPause
  | TimerUpdate Time.Time
  | UseSecondKnob Bool

type alias File = String

type alias Model =
  { mouse: Maybe Drag

  , status: Status

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

