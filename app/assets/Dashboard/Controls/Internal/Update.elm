module Controls.Internal.Update exposing (update)

import Controls.Internal.ModelUtils exposing(..)
import Controls.Types exposing (Msg(..), Model, Drag, Status(..))
import GameModel exposing (..)

update : Timestamp -> GameLength -> Msg -> Model -> (Timestamp, Model)
update timestamp gameLength msg ({mouse} as model) =
  case msg of
      KnobGrab pos ->
        ( timestamp
        , { model | mouse = Just <| Drag pos pos }
        )
      KnobMove pos ->
        ( timestamp
        , { model | mouse = Maybe.map (\{start} -> Drag start pos) mouse }
        )
      KnobRelease pos ->
        ( getTimestampAtMouse model timestamp gameLength
        , { model | mouse = Nothing }
        )
      BarClick (pos, rel) ->
        ( getTimestampAtPixel gameLength rel
        , { model | mouse = Just <| Drag pos pos }
        )
      PlayPause ->
        ( case (timestamp >= gameLength, model.status) of
            (True, _) -> 0
            (False, Play) -> timestamp
            (False, Pause) -> timestamp + 1
        , { model | status = toggleStatus model.status }
        )
      TimerUpdate _ ->
        if timestamp >= gameLength then
          ( timestamp
          , { model | status = Pause }
          )
        else
          ( timestamp + 1
          , model
          )
