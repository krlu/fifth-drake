module Models exposing (..)

import Mouse

type alias Model =
  { value: Int
  , maxVal: Int
  , mouse: Maybe Drag
  , width: Float
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

  , width = 500
  }

getCurrentValue : Model -> Int
getCurrentValue {value, maxVal, mouse, width} =
  case mouse of
    Nothing -> value
    Just {start, current} ->
      let
          delta = current.x - start.x |> toFloat
      in
          max 0 << min maxVal <| value + truncate (delta / width * maxVal)

getCurrentPx : Model -> Float
getCurrentPx ({width, maxVal} as model) =
  getCurrentValue model
    |> toFloat
    |> \val -> val / (toFloat maxVal) * width

