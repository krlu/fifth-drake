module Minimap.Internal.Populate exposing (..)

import Dict
import Http
import Json.Decode exposing (Decoder, list, array, object2, (:=), int, float, string)
import Maybe exposing (withDefault)
import Minimap.Types exposing (Game, Player, PlayerState, Position, ChampionState, Msg(..))
import Task exposing (Task)
import Types exposing (WindowLocation)

playerUrl : WindowLocation -> String
playerUrl loc =
  Http.url ("http://" ++ loc.host ++ "/game/" ++ loc.gameId ++ "/data") []

getGameData : WindowLocation -> Task Http.Error (List Player)
getGameData loc = Http.get (game) <| playerUrl loc

populate : WindowLocation -> Cmd Msg
populate loc = Task.perform PlayerFetchFailure SetData <| getGameData loc

game : Decoder Game
game =
  object2 Game
    ("blueTeam" := array player)
    ("redTeam" := array player)

player : Decoder Player
player =
  object2 Player
    ("role" := int)
    ("championName" := string)
    ("ign" := string)
    ("side" := string)
    ("state" := array playerState)

playerState : Decoder PlayerState
playerState =
  object2 PlayerState
    ("position" := position)
    ("championState" := championState)

position : Decoder Position
position =
  object2 Position
    ("x" := int)
    ("y" := int)

championState : Decoder ChampionState
championState =
  object2 ChampionState
    ("hp" := string)
    ("mp" := string)
    ("xp" := string)

