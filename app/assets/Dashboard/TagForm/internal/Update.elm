module TagForm.Internal.Update exposing (..)

import Http exposing (RawError,Response)
import TagForm.Internal.Save exposing (sendRequest)
import TagForm.Internal.SaveTypes exposing (Msg(TagSaveFailure, TagSaved))
import TagForm.Types as Types exposing (..)

update : Types.Msg -> Model -> (Model, Cmd Types.Msg)
update msg model =
  case msg of
   CreateTitle title ->
    ({model | title = title }, Cmd.none)
   CreateDescription description ->
    ({model | description = description}, Cmd.none)
   CreateCategory category ->
    ({model | category = category}, Cmd.none)
   AddPlayers ign ->
    ({model | players = ign }, Cmd.none)
   CancelForm ->  -- TODO: should hide the form
    (model, Cmd.none)
   SaveTag ->
    (model, Cmd.map SuccessOrFail (sendRequest model))
   SuccessOrFail (TagSaved res) ->
    (model, Cmd.none)
   SuccessOrFail (TagSaveFailure err) ->
    (model, Cmd.none)

