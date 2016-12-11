module TagCarousel.Internal.Update exposing (..)

import GameModel exposing (Timestamp)
import TagCarousel.Types exposing (Model, Msg(..))

update : Msg -> Model -> (Maybe Timestamp, Model)
update msg model =
  case msg of
    TagClick val -> (Just val, model)
    UpdateTags (Ok tags) -> (Nothing, { model | tags = tags })
    UpdateTags (Err err) -> (Nothing, Debug.log "Tags failed to fetch" model)
