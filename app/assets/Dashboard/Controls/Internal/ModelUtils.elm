module Controls.Internal.ModelUtils exposing (..)

import Controls.Css exposing (timelineWidth)
import Controls.Types exposing (Drag, Model, Status(..))
import GameModel exposing (..)
import Mouse
import String

getTimestampAtMouse : Maybe Drag -> Timestamp -> GameLength -> Timestamp
getTimestampAtMouse mouse timestamp gameLength =
  case mouse of
    Nothing -> timestamp
    Just {start, current} ->
      let
        delta = current.x - start.x |> toFloat
      in
        max 0 << min gameLength <| timestamp + truncate (delta / timelineWidth * toFloat gameLength)

getPixelForTimestamp : Model -> Timestamp -> GameLength -> Float
getPixelForTimestamp model timestamp gameLength =
  getTimestampAtMouse model.mouse timestamp gameLength
    |> toFloat
    |> \val -> val / (toFloat gameLength) * timelineWidth

getTimestampAtPixel : GameLength -> Mouse.Position -> Timestamp
getTimestampAtPixel gameLength pos =
  let
    x = toFloat pos.x
    max = toFloat gameLength
  in
    round <| x * max / timelineWidth

toggleStatus : Status -> Status
toggleStatus x =
  case x of
    Play -> Pause
    Pause -> Play

toTimeString : Timestamp -> String
toTimeString val =
  let
    removeHour : Int -> Maybe Int
    removeHour i =
      case i of
        0 -> Nothing
        _ -> Just i
  in
    [ flip (//) 3600 -- Hours
      >> removeHour
    , flip (//) 60
      >> flip (%) 60 -- Minutes
      >> Just
    , flip (%) 60 -- Seconds
      >> Just
    ]
    |> List.filterMap (\x -> x val)
    |> List.map toString
    |> List.map (String.padLeft 2 '0')
    |> String.join ":"
