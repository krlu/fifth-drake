module Timeline.Models exposing (..)

import Mouse

type alias Value = Int

type alias Model =
  { value: Value
  , maxVal: Value
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

getCurrentValue : Model -> Value
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

getValueAt : Model -> Mouse.Position -> Value
getValueAt {width, maxVal} pos =
  let
    x = toFloat pos.x
    max = toFloat maxVal
  in
    truncate <| x * max / width - 1
