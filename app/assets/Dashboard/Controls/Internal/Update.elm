module Controls.Internal.Update exposing (update)

import Controls.Internal.ModelUtils exposing(..)
import Controls.Types exposing (..)
import GameModel exposing (..)
import PlaybackTypes exposing (..)

update : Timestamp -> GameLength -> Msg -> Model -> (Timestamp, Model)
update timestamp gameLength msg ({lastPosition} as model) =
  case msg of
      KnobMove pos ->
        let
          timestamp_ =
            case lastPosition of
              Nothing ->
                Just timestamp
              Just lastPosition ->
                getTimestampAtMouse lastPosition pos timestamp gameLength
        in
          ( Maybe.withDefault timestamp timestamp_
          , { model
            | lastPosition =
              case timestamp_ of
                Nothing ->
                  lastPosition
                Just _ ->
                  Just pos
            }
          )
      KnobRelease pos ->
        update timestamp gameLength (KnobMove pos) model
        |> Tuple.mapSecond
          (\model_ ->
            { model_ | lastPosition = Nothing }
          )
      BarClick (pos, rel) ->
        update (getTimestampAtPixel gameLength rel) gameLength (KnobMove pos) model
      PlayPause ->
        ( case (timestamp >= gameLength, model.status) of
            (True, _) -> 0
            (False, Play) -> timestamp
            (False, Pause) -> timestamp + 1
        , { model
          | status = toggleStatus model.status
          }
        )
