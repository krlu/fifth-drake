module Minimap.Internal.Populate exposing (..)

import Dict
import Http
import Json.Decode exposing (Decoder, list, array, object2, object3, object5, (:=), int, float, string)
import Maybe exposing (withDefault)
import Minimap.Types exposing (Game, Player, PlayerState, Position, ChampionState, Msg(..))
import Task exposing (Task)
import Types exposing (WindowLocation)

playerUrl : WindowLocation -> String
playerUrl loc =
  Http.url ("http://" ++ loc.host ++ "/game/" ++ loc.gameId ++ "/data") []

getGameData : WindowLocation -> Task Http.Error Game
getGameData loc = Http.get game <| playerUrl loc

populate : WindowLocation -> Cmd Msg
populate loc = Task.perform PlayerFetchFailure SetData <| getGameData loc

game : Decoder Game
game =
  object2 Game
    ("blueTeam" := array player)
    ("redTeam" := array player)

player : Decoder Player
player =
  object5 Player
    ("side" := string)
    ("role" := string)
    ("ign" := string)
    ("championName" := string)
    ("playerStates" := array playerState)

playerState : Decoder PlayerState
playerState =
  object2 PlayerState
    ("position" := position)
    ("championState" := championState)

position : Decoder Position
position =
  object2 Position
    ("x" := float)
    ("y" := float)

championState : Decoder ChampionState
championState =
  object3 ChampionState
    ("hp" := float)
    ("mp" := float)
    ("xp" := float)

