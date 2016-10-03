module Minimap.Update exposing (..)

import Minimap.Messages exposing (Msg(..))
import Minimap.Models exposing (Model)

update : Msg -> Model -> (Model, Cmd Msg)
update (SetPlayers players) model =
  ({ model | players = players }, Cmd.none)
