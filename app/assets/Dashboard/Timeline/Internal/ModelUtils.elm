module Timeline.Internal.ModelUtils exposing (..)

import Mouse
import Timeline.Css exposing (timelineWidth)
import Timeline.Types exposing (Model, Status(..), Value)

getCurrentValue : Model -> Value
getCurrentValue {value, maxVal, mouse} =
  case mouse of
    Nothing -> value
    Just {start, current} ->
      let
        delta = current.x - start.x |> toFloat
      in
        max 0 << min maxVal <| value + truncate (delta / timelineWidth * maxVal)

getCurrentPx : Model -> Float
getCurrentPx ({maxVal} as model) =
  getCurrentValue model
    |> toFloat
    |> \val -> val / (toFloat maxVal) * timelineWidth

getValueAt : Model -> Mouse.Position -> Value
getValueAt {maxVal} pos =
  let
    x = toFloat pos.x
    max = toFloat maxVal
  in -- Subtract 1 pixel to make clicking feel right.
    truncate <| x * max / timelineWidth - 1

toggleStatus : Status -> Status
toggleStatus x =
  case x of
    Play -> Pause
    Pause -> Play
