--created entire file
module Populate exposing (..)

import Array
import Dict
import GameModel exposing (..)
import Http
import Json.Decode exposing (..)
import Maybe exposing (withDefault)
import Navigation exposing (Location)
import Types exposing (..)

(::=) : String -> Decoder a -> Decoder a
(::=) key decoder =
  value
  |> andThen (\v ->
    case decodeValue (field key decoder) v of
      Ok val -> succeed val
      Err e -> Debug.log (key ++ " failed to parse") (fail e))

populate : String -> GameId -> Cmd Msg
populate host gameId = Http.send SetGame <| getGame host gameId

getGame : String -> GameId -> Http.Request Game
getGame host gameId = Http.get (playerUrl host gameId) game

playerUrl : String -> GameId -> String
playerUrl host gameId =
  "http://" ++ host ++ "/game/" ++ toString gameId ++ "/data"

game : Decoder Game
game =
  map2 Game
    ("metadata" ::= metadata)
    ("data" ::= data)

metadata : Decoder Metadata
metadata =
  map3 Metadata
    ("blueTeamName" ::= string)
    ("redTeamName" ::= string)
    ("gameLength" ::= gameLength)

gameLength : Decoder GameLength
gameLength = int

data : Decoder Data
data =
  map2 Data
    ("blueTeam" ::= team)
    ("redTeam" ::= team)

team : Decoder Team
team =
  map2 Team
    ("teamStates" ::= array teamState)
    ("players" ::= array player)

teamState : Decoder TeamState
teamState =
  map3 TeamState
    ("dragons" ::= int)
    ("barons" ::= int)
    ("turrets" ::= int)

player : Decoder Player
player =
  map6 Player
    ("side" ::= side)
    ("role" ::= role)
    ("ign" ::= string)
    ("championName" ::= string)
    ("championImage" ::= string)
    ("playerStates" ::= array playerState)

side : Decoder Side
side =
  string
  |> andThen (\s ->
    case s of
     "red" -> succeed Red
     "blue" -> succeed Blue
     _ -> fail <| s ++ " is not a proper side type")

role : Decoder Role
role =
  string
  |> andThen (\s ->
    case s of
      "top" ->      succeed Top
      "jungle" ->   succeed Jungle
      "mid" ->      succeed Mid
      "bot" ->      succeed Bot
      "support" ->  succeed Support
      _ -> fail <| s ++ " is not a proper role type")

playerState : Decoder PlayerState
playerState =
  map2 PlayerState
    ("position" ::= position)
    ("championState" ::= championState)

position : Decoder Position
position =
  map2 Position
    ("x" ::= float)
    ("y" ::= float)

championState : Decoder ChampionState
championState =
  map3 ChampionState
    ("hp" ::= float)
    ("mp" ::= float)
    ("xp" ::= float)
