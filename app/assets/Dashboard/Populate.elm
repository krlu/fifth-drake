--created entire file
module Populate exposing (..)

import Array
import Dict
import GameModel exposing (..)
import Http
import Json.Decode exposing (..)
import Maybe exposing (withDefault)
import Types exposing (..)
import Task exposing (Task)
import Types exposing (WindowLocation)

(::=) : String -> Decoder a -> Decoder a
(::=) key decoder =
  customDecoder value <| \v ->
    case decodeValue (key := decoder) v of
      Ok val -> Ok val
      Err e -> Debug.log (key ++ " failed to parse") (Err e)

populate : WindowLocation -> Cmd Msg
populate loc = Task.perform GameDataFetchFailure SetGame <| getGame loc

getGame : WindowLocation -> Task Http.Error Game
getGame loc = Http.get game <| playerUrl loc

playerUrl : WindowLocation -> String
playerUrl loc =
  Http.url ("http://" ++ loc.host ++ "/game/" ++ loc.gameId ++ "/data") []

game : Decoder Game
game =
  object2 Game
    ("metadata" ::= metadata)
    ("data" ::= data)

metadata : Decoder Metadata
metadata =
  object3 Metadata
    ("blueTeamName" ::= string)
    ("redTeamName" ::= string)
    ("gameLength" ::= gameLength)

gameLength : Decoder GameLength
gameLength = int

data : Decoder Data
data =
  object2 Data
    ("blueTeam" ::= team)
    ("redTeam" ::= team)

team : Decoder Team
team =
  object2 Team
    ("teamStates" ::= array teamState)
    ("players" ::= array player)

teamState : Decoder TeamState
teamState =
  object3 TeamState
    ("dragons" ::= int)
    ("barons" ::= int)
    ("turrets" ::= int)

player : Decoder Player
player =
  object6 Player
    ("side" ::= side)
    ("role" ::= role)
    ("ign" ::= string)
    ("championName" ::= string)
    ("championImage" ::= string)
    ("playerStates" ::= array playerState)

side : Decoder Side
side = customDecoder string <| \s ->
  case s of
   "red" ->    Ok Red
   "blue" ->   Ok Blue
   _ -> Err <| s ++ " is not a proper side type"

role : Decoder Role
role = customDecoder string <| \s ->
  case s of
    "top" ->      Ok Top
    "jungle" ->   Ok Jungle
    "mid" ->      Ok Mid
    "bot" ->      Ok Bot
    "support" ->  Ok Support
    _ -> Err <| s ++ " is not a proper role type"

playerState : Decoder PlayerState
playerState =
  object2 PlayerState
    ("position" ::= position)
    ("championState" ::= championState)

position : Decoder Position
position =
  object2 Position
    ("x" ::= float)
    ("y" ::= float)

championState : Decoder ChampionState
championState =
  object3 ChampionState
    ("hp" ::= float)
    ("mp" ::= float)
    ("xp" ::= float)
