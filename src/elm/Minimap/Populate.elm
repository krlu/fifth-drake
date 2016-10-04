module Minimap.Populate exposing (..)

import Json.Decode exposing (Decoder, list, object3, (:=), int, float)
import Minimap.Messages exposing (Msg(..))
import Minimap.Models exposing (Player)
import Http
import StyleUtils exposing (..)
import Task exposing (Task)

playerUrl : String
playerUrl = Http.url "http://localhost:4000/players" []

getPlayers : Task Http.Error (List Player)
getPlayers = Http.get (list player) playerUrl

populate : Cmd Msg
populate = Task.perform PlayerFetchFailure SetPlayers getPlayers

player : Decoder Player
player =
  object3 Player
    ("id" := int)
    ("x" := float)
    ("y" := float)
