module Controls.Types exposing (..)

import Http
import Mouse
import PlaybackTypes exposing (..)
import Time

type Msg
  = KnobMove Mouse.Position
  | KnobRelease Mouse.Position
  | BarClick (Mouse.Position, Mouse.Position)
  | PlayPause

type alias File = String

type alias Model =
  { lastMousePosition: Maybe Drag
  , status: Status
  , pauseButton: File
  , playButton: File
  }

type alias Drag = Mouse.Position
