module Minimap.Populate exposing (..)

import Json.Decode exposing (Decoder, list, array, object2, (:=), int, float)
import Minimap.Messages exposing (Msg(..))
import Minimap.Models exposing (Player, PlayerState)
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
  object2 Player
    ("id" := int)
    ("state" := array playerState)

playerState : Decoder PlayerState
playerState =
  object2 PlayerState
    ("x" := float)
    ("y" := float)
