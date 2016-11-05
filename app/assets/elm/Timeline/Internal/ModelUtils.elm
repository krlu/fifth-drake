module Timeline.Internal.ModelUtils exposing (..)

import Mouse
import Timeline.Types exposing (Model, Status(..), Value)

initialModel : {a | playButton: String, pauseButton: String} -> Model
initialModel {playButton, pauseButton} =
  { value = 0
  , maxVal = 100
  , mouse = Nothing
  , status = Pause
  , width = 462 -- Need to figure out how to do this better.
  , pauseButton = pauseButton
  , playButton = playButton
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
  in -- Subtract 1 pixel to make clicking feel right.
    truncate <| x * max / width - 1

toggleStatus : Status -> Status
toggleStatus x =
  case x of
    Play -> Pause
    Pause -> Play
