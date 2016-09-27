module Messages exposing (..)

import Mouse

type Msg = KnobGrab Mouse.Position
         | KnobMove Mouse.Position
         | KnobRelease Mouse.Position
