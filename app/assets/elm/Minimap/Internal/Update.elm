module Minimap.Internal.Update exposing (..)

import Minimap.Types exposing (..)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    SetPlayers players ->
      ({ model | players = players }, Cmd.none)
    PlayerFetchFailure err ->
      (Debug.log "Player failed to fetch" model, Cmd.none)
    UpdateTimestamp timestamp ->
      ({model | timestamp = timestamp }, Cmd.none)
