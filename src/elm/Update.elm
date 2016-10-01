module Update exposing (update)

import Messages exposing (Msg(..))
import Models exposing (..)

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
      { model | value = getValueAt model pos }
