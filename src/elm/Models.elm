module Models exposing (..)

import Mouse

type alias Model =
  { value: Int
  , maxVal: Int
  , mouse: Maybe Drag
  }

type alias Drag =
  { start: Mouse.Position
  , current: Mouse.Position
  }

initialModel : Model
initialModel =
  { value = 50
  , maxVal = 100
  , mouse = Nothing
  }

getCurrentValue : Model -> Int
getCurrentValue {value, maxVal, mouse} =
  case mouse of
    Nothing -> value
    Just {start, current} ->
      max 0 << min maxVal <| value + (current.x - start.x)
