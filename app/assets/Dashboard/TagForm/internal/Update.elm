module TagForm.Internal.Update exposing (..)

import GameModel exposing (Player, Timestamp)
import Http exposing (Response)
import TagForm.Internal.Save exposing (sendRequest)
import TagForm.Internal.SaveTypes exposing (Msg(TagSaved))
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
    ({model | players = ign }, Cmd.none)
   CancelForm ->  -- TODO: should hide the form
    (model, Cmd.none)
   SaveTag ->
    (model, Cmd.map SuccessOrFail (sendRequest model ts players))
   SuccessOrFail msg ->
    (model, Cmd.none)

