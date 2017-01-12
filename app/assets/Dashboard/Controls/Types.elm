module Controls.Types exposing (..)

import Minimap.Types exposing (Action)
import Mouse
import Time
import Http


type Msg
  = KnobMove Mouse.Position
  | KnobRelease Mouse.Position
  | BarClick (Mouse.Position, Mouse.Position)
  | PlayPause
  | TimerUpdate Time.Time

type alias File = String

type alias Model =
  { lastPosition: Maybe Drag

  , status: Status

  , action: Action

  , pauseButton: File
  , playButton: File
  }

type alias Drag = Mouse.Position

type Status
  = Play
  | Pause

