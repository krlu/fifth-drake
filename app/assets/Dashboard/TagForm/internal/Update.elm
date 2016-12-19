module TagForm.Internal.Update exposing (..)

import GameModel exposing (Player, Timestamp)
import Http exposing (Response)
import TagForm.Internal.Save exposing (sendRequest)
import TagForm.Types as Types exposing (..)
import TagCarousel.TagCarousel as TagCarousel

update : Types.Msg -> Model -> Timestamp -> List Player -> (Model, Cmd Types.Msg)
update msg model ts players =
  case msg of
   CreateTitle title ->
    ({model | title = title }, Cmd.none)
   CreateDescription description ->
    ({model | description = description}, Cmd.none)
   CreateCategory category ->
    ({model | category = category}, Cmd.none)
   AddPlayers ign ->
    ({model | players = ign}, Cmd.none)
   CancelForm ->  -- TODO: should hide the form
    (model, Cmd.none)
   SaveTag ->
    (model, sendRequest model ts players)
   TagSaved (Ok tags) ->
    (model, Cmd.none)
   TagSaved (Err tags) ->
    (model, Cmd.none)

