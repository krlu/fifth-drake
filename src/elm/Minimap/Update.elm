module Minimap.Update exposing (..)

import Minimap.Messages exposing (Msg(..))
import Minimap.Models exposing (Model)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    SetPlayers players ->
      ({ model | players = players }, Cmd.none)
    PlayerFetchFailure err ->
      (Debug.log "Player failed to fetch" model, Cmd.none)
