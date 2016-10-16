module TagScroller.Update exposing (..)

import TagScroller.Models exposing (Model)
import TagScroller.Messages exposing (Msg(..))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    TagClick _ -> (model, Cmd.none)
    UpdateTags tags -> ( { model | tags = tags }, Cmd.none)
    TagFetchFailure err -> (Debug.log "Tags failed to fetch" model, Cmd.none)
