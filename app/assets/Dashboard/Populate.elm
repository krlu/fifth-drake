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
import UrlParser exposing ((</>), parsePath, s)

getGameId : Location -> GameId
getGameId =
  parsePath (s "game" </> UrlParser.int)
  >> \maybe ->
    case maybe of
      Just gameId -> gameId
      Nothing -> Debug.crash "No game id found in URL"

(::=) : String -> Decoder a -> Decoder a
(::=) key decoder =
  value
  |> andThen (\v ->
    case decodeValue (field key decoder) v of
      Ok val -> succeed val
      Err e -> Debug.log (key ++ " failed to parse") (fail e))

populate : Location -> Cmd Msg
populate loc = Http.send SetGame <| getGame loc

getGame : Location -> Http.Request Game
getGame loc = Http.get (playerUrl loc) game

playerUrl : Location -> String
playerUrl loc =
  loc.origin ++ "/game/" ++ toString (getGameId loc) ++ "/data"

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
  map5 ChampionState
    ("hp" ::= float)
    ("hpMax" ::= float)
    ("power" ::= float)
    ("powerMax" ::= float)
    ("xp" ::= float)
