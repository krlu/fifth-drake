module TagScroller.Internal.Update exposing (..)

import GameModel exposing (Timestamp)
import TagScroller.Types exposing (Model, Msg(..))

update : Msg -> Model -> (Maybe Timestamp, Model)
update msg model =
  case msg of
    TagClick val -> (Just val, model)
    UpdateTags tags -> (Nothing, { model | tags = tags })
    TagFetchFailure err -> (Nothing, Debug.log "Tags failed to fetch" model)
