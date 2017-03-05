module HomeTypes exposing (..)

import GameModel exposing (GameLength)
import Http
import Json.Decode exposing (..)
import Navigation exposing (Location)

type Msg
  = SearchGame String
  | LocationUpdate Location
  | GetGames (Result Http.Error (List MetaData))

type alias GameKey = String
type alias GameDateEpoch = Float
type alias Query = String

type alias Flags =
  {

  }

type alias MetaData =
  { gameLength : GameLength
  , blueTeamName : String
  , redTeamName : String
  , vodURL : String
  , gameKey : GameKey
  , gameNumber : Int
  , timeFrame : TimeFrame
  , tournament : Tournament
  }

type alias TimeFrame =
  { gameDate : GameDateEpoch
  , week : Int
  }
type alias Tournament =
  { year : Int
  , split : String
  , phase : String
  , league : String
  }

type alias Model =
  { games : List MetaData
  , query : String
  , location : Location
  }
