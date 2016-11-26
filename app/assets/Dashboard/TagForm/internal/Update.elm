module TagForm.Internal.Update exposing (..)

import TagForm.Types exposing (..)

update : Msg -> Model -> (Model, Cmd Msg)
update msg content =
  case msg of
    TagSave content -> (content, Cmd.none)
    TagSaveFailure err -> (Debug.log "Tag Failed to Save" content, Cmd.none)
