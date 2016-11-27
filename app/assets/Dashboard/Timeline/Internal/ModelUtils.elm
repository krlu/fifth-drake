module Timeline.Internal.ModelUtils exposing (..)

import GameModel exposing (..)
import Mouse
import Timeline.Css exposing (timelineWidth)
import Timeline.Types exposing (Model, Status(..))

getTimestampAtMouse : Model -> Timestamp -> GameLength -> Timestamp
getTimestampAtMouse {mouse} timestamp gameLength =
  case mouse of
    Nothing -> timestamp
    Just {start, current} ->
      let
        delta = current.x - start.x |> toFloat
      in
        max 0 << min gameLength <| timestamp + truncate (delta / timelineWidth * gameLength)

getPixelForTimestamp : Model -> Timestamp -> GameLength -> Float
getPixelForTimestamp model timestamp gameLength =
  getTimestampAtMouse model timestamp gameLength
    |> toFloat
    |> \val -> val / (toFloat gameLength) * timelineWidth

getTimestampAtPixel : GameLength -> Mouse.Position -> Timestamp
getTimestampAtPixel gameLength pos =
  let
    x = toFloat pos.x
    max = toFloat gameLength
  in -- Subtract 1 pixel to make clicking feel right.
    truncate <| x * max / timelineWidth - 1

toggleStatus : Status -> Status
toggleStatus x =
  case x of
    Play -> Pause
    Pause -> Play
