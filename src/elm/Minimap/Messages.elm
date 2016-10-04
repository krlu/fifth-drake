module Minimap.Messages exposing (..)

import Http
import Minimap.Models exposing (..)

type Msg
  = SetPlayers (List Player)
  | PlayerFetchFailure Http.Error
