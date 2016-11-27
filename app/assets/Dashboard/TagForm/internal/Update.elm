module TagForm.Internal.Update exposing (..)

import TagForm.Types exposing (..)
import TagForm.Types exposing(Model)
import Timeline.Types as TimelineT

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
   CreateTitle title ->
    ({model | title = title }, Cmd.none)
   CreateDescription description ->
    ({model | description = description}, Cmd.none)
   CreateCategory category ->
    ({model | category = category}, Cmd.none)
   CreateTimeStamp ->
    (model, Cmd.none)
   AddPlayers ign ->
    ({model | players = ign }, Cmd.none)
   CancelForm ->  -- TODO: should hide the form
    (model, Cmd.none)
   SaveTag ->
    (model, Cmd.none) -- TODO: cmd should call request creation
