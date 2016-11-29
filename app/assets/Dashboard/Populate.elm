--created entire file
module Populate exposing (..)

import Dict
import GameModel exposing (..)
import Http
import Json.Decode exposing (..)
import Maybe exposing (withDefault)
import Types exposing (..)
import Task exposing (Task)
import Types exposing (WindowLocation)

playerUrl : WindowLocation -> String
playerUrl loc =
  Http.url ("http://" ++ loc.host ++ "/game/" ++ loc.gameId ++ "/data") []

getGameData : WindowLocation -> Task Http.Error GameData
getGameData loc = Http.get game <| playerUrl loc

role : Decoder Role
role = customDecoder string <| \s ->
  case s of
    "top" ->      Ok Top
    "jungle" ->   Ok Jungle
    "mid" ->      Ok Mid
    "bot" ->      Ok Bot
    "support" ->  Ok Support
    _ -> Err <| s ++ " is not a proper role type"

side : Decoder Side
side = customDecoder string <| \s ->
  case s of
   "red" ->    Ok Red
   "blue" ->   Ok Blue
   _ -> Err <| s ++ " is not a proper side type"

populate : WindowLocation -> Cmd Msg
populate loc = Task.perform GameDataFetchFailure SetGameData <| getGameData loc

game : Decoder GameData
game =
  object2 GameData
    ("blueTeam" := team)
    ("redTeam" := team)

team : Decoder Team
team =
  object2 Team
    ("teamStates" := array teamState)
    ("players" := array player)

teamState : Decoder TeamState
teamState =
  object3 TeamState
    ("dragons" := int)
    ("barons" := int)
    ("turrets" := int)

player : Decoder Player
player =
  object5 Player
    ("side" := side)
    ("role" := role)
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
  object6 ChampionState
    ("hp" := float)
    ("mp" := float)
    ("xp" := float)
    ("hpMax" := float)
    ("mpMax" := float)
    ("xpNextLevel" := float)

gameLength : Decoder GameLength
gameLength = ("gameLength" := int)