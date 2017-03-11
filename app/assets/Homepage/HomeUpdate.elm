module HomeUpdate exposing (update)

import HomeTypes exposing (..)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    LocationUpdate loc -> (model, Cmd.none)
    SearchGame query -> ({ model | query = query }, Cmd.none)
    GetGames (Ok games) ->({ model | games = games }, Cmd.none)
    GetGames (Err err) -> (Debug.log "Games failed to fetch!" model, Cmd.none)
