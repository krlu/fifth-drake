module TagForm.Internal.Update exposing (..)

import TagForm.Types exposing (..)

update : Msg -> Model -> (Model, Cmd Msg)
update (Msg content) oldContent =
  case Msg of
    TagSave -> content
    TagSaveFailure err -> (Debug.log "Tag Failed to Save" content, Cmd.none)
