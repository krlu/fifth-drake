module Timeline.Messages exposing (..)

import Mouse

type Msg = KnobGrab Mouse.Position
         | KnobMove Mouse.Position
         | KnobRelease Mouse.Position
         | BarClick Mouse.Position
