module TagCarousel.Internal.Update exposing (..)

import GameModel exposing (Timestamp)
import TagCarousel.Types exposing (Model, Msg(..))
import String as String
import TagCarousel.Internal.Delete exposing (sendRequest)

update : Msg -> Model -> (Maybe Timestamp, Model, Cmd Msg) -- (TODO: change to Model, Cmd Msg)
update msg model =
  case msg of
    TagClick val -> (Just val, model, Cmd.none)
    UpdateTags (Ok tags) -> (Nothing, { model | tags = tags }, Cmd.none)
    UpdateTags (Err err) -> (Nothing, Debug.log "Tags failed to fetch" model, Cmd.none)
    DeleteTag id -> (Nothing, model, Cmd.map SuccessOrFail (sendRequest id model.host))
    SuccessOrFail msg -> (Nothing, model, Cmd.none)
