module Timeline.Internal.Update exposing (update)

import GameModel exposing (..)
import Timeline.Internal.ModelUtils exposing(..)
import Timeline.Types exposing (Msg(..), Model, Drag, Status(..))

update : Timestamp -> GameLength -> Msg -> Model -> (Model, Cmd Msg)
update timestamp gameLength msg ({mouse} as model) =
  let
    model' : Model
    model' =
      case msg of
          KnobGrab pos ->
            { model | mouse = Just <| Drag pos pos }
          KnobMove pos ->
            { model | mouse = Maybe.map (\{start} -> Drag start pos) mouse }
          KnobRelease pos ->
            { model | mouse = Nothing, timestamp = getTimestampAtMouse model timestamp gameLength }
          BarClick (pos, rel) ->
            { model | mouse = Just <| Drag pos pos, timestamp = getTimestampAtPixel gameLength rel }
          PlayPause ->
            { model | status = toggleStatus model.status
                    , timestamp =
                        case (timestamp >= gameLength, model.status) of
                          (True, _) -> 0
                          (False, Play) -> timestamp
                          (False, Pause) -> timestamp + 1
            }
          TimerUpdate _ ->
            if timestamp >= gameLength then
              { model | status = Pause }
            else
              { model | timestamp = timestamp + 1 }
          GameLengthFetchFailure err ->
            (Debug.log "Timeline failed to fetch" model)
  in
    (model', Cmd.none)