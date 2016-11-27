module Timeline.Types exposing (..)

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
  | SetValue Value
  | GameLengthFetchFailure Http.Error
  | SetTimelineLength GameLength

type alias Value = Int
type alias File = String
type alias GameLength = Int

type alias Model =
  { value: Value
  , maxVal: GameLength
  , mouse: Maybe Drag

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

