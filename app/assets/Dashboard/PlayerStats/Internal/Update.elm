module PlayerStats.Internal.Update exposing (..)

import PlayerStats.Types exposing (..)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    -- the msg types go here
    SetData ->
      ({}, Cmd.none)