module Controls.Internal.ModelUtils exposing (..)

import Controls.Css exposing (timelineWidth)
import Controls.Types exposing (Model)
import GameModel exposing (..)
import Mouse
import PlaybackTypes exposing (Status(..))
import String

getTimestampAtMouse : Mouse.Position -> Mouse.Position -> Timestamp -> GameLength -> Maybe Timestamp
getTimestampAtMouse last current timestamp gameLength =
  let
    delta = current.x - last.x |> toFloat
    timestamp_ = timestamp + truncate (delta / timelineWidth * toFloat gameLength)
  in
    case (timestamp_ > 0, timestamp_ < gameLength) of
      (True, True) ->
        Just timestamp_
      _ ->
        Nothing

getPixelForTimestamp : Timestamp -> GameLength -> Float
getPixelForTimestamp timestamp gameLength =
  (toFloat timestamp) / (toFloat gameLength) * timelineWidth

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
