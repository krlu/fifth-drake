module HomePopulate exposing (..)

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
  map6 MetaData
    ( field "gameLength" gameLength )
    ( field "blueTeamName" string )
    ( field "redTeamName" string )
    ( field "gameDate" float )
    ( field "vodURL" string )
    ( field "gameKey" string)

gameLength : Decoder GameLength
gameLength = int
