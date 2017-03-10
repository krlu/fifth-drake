module HomePopulate exposing (populate)

import HomeTypes exposing (..)
import GameModel exposing (GameLength)
import Http
import Json.Decode exposing (..)
import Navigation exposing (Location)


populate : Location -> Cmd Msg
populate loc = Http.send GetGames <| getGames loc

getGames : Location -> Http.Request (List MetaData)
getGames loc = Http.get (gamesUrl loc) (list metadata)

gamesUrl : Location -> String
gamesUrl loc =  loc.origin ++ "/games"

metadata : Decoder MetaData
metadata =
  map8 MetaData
    ( field "gameLength" gameLength )
    ( field "blueTeamName" string )
    ( field "redTeamName" string )
    ( field "vodURL" string )
    ( field "gameKey" string )
    ( field "gameNumber" int)
    ( field "timeFrame" timeFrame )
    ( field "tournament" tournament )


timeFrame : Decoder TimeFrame
timeFrame =
  map3 TimeFrame
    ( field "gameDate" gameDate)
    ( field "week" int)
    ( field "patch" string)

tournament : Decoder Tournament
tournament =
  map4 Tournament
    ( field "year" int)
    ( field "split" string)
    ( field "phase" string)
    ( field "league" string)

gameLength : Decoder GameLength
gameLength = int

gameDate : Decoder GameDateEpoch
gameDate = float


