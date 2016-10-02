module Update exposing (..)

import Messages exposing (Msg(..))
import Models exposing (Model)
import Timeline.Update as TUpdate

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    TimelineMsg m ->
      let
        (tmodel, tcmds) = TUpdate.update m model.timeline
      in
        ( { model | timeline = tmodel }
        , Cmd.map TimelineMsg tcmds
        )
