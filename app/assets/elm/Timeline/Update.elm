module Timeline.Update exposing (update)

import Timeline.Messages exposing (Msg(..))
import Timeline.Models exposing (..)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = (update' msg model, Cmd.none)

update' : Msg -> Model -> Model
update' msg ({value, mouse} as model) =
  case msg of
    KnobGrab pos ->
      { model | mouse = Just <| Drag pos pos }
    KnobMove pos ->
      { model | mouse = Maybe.map (\{start} -> Drag start pos) mouse }
    KnobRelease pos ->
      { model | mouse = Nothing, value = getCurrentValue model }
    BarClick pos ->
      { model | mouse = Just <| Drag pos pos, value = getValueAt model pos }
    PlayPause ->
      { model | status = toggleStatus model.status
              , value =
                  case (model.value >= model.maxVal, model.status) of
                    (True, _) -> 0
                    (False, Play) -> model.value
                    (False, Pause) -> model.value + 1
      }
    TimerUpdate _ ->
      if model.value >= model.maxVal then
        { model | status = Pause }
      else
        { model | value = model.value + 1 }
