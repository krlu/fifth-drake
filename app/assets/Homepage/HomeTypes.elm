module HomeTypes exposing (..)

import GameModel exposing (GameLength)
import Http
import Json.Decode exposing (..)
import Navigation exposing (Location)
import Set exposing (Set)

type Msg
  = SearchGame
  | LocationUpdate Location
  | GetGames (Result Http.Error (List MetaData))

type alias GameKey = String

type alias Flags =
  {

  }

type alias MetaData =
  { gameLength : GameLength
  , blueTeamName : String
  , redTeamName : String
  , gameDate : Float
  , voURL : String
  , gameKey : GameKey
  }

type alias Model =
  { games : List MetaData
  , selectedGames : Set GameKey
  , location : Location
  }
