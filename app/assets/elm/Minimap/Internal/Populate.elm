module Minimap.Internal.Populate exposing (..)

import Dict
import Http
import Json.Decode exposing (Decoder, list, array, object2, (:=), int, float)
import Maybe exposing (withDefault)
import Minimap.Types exposing (Player, PlayerState, Msg(..))
import Task exposing (Task)
import Types exposing (Location)

(=>) = (,)

playerUrl : Location -> String
playerUrl loc =
  Http.url ("http://" ++ loc.host ++ "/game/" ++ loc.gameId ++ "/data") []

getPlayers : Location -> Task Http.Error (List Player)
getPlayers loc = Http.get (list player) <| playerUrl loc

populate : Location -> Cmd Msg
populate loc = Task.perform PlayerFetchFailure SetPlayers <| getPlayers loc

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
