module GameModel exposing (..)

import Array exposing (Array)

type alias GameId = Int
type alias PlayerId = String
type alias GameLength = Timestamp
type alias Timestamp = Int
type alias Ign = String
type alias Name = String
type alias Image = String
type alias ParticipantId = Int

type alias Game =
  { metadata : Metadata
  , data : Data
  }

{-| This represents all metadata in a game.
gameLength is the total duration of the game in seconds.
-}
type alias Metadata =
  { blueTeamName       : String
  , redTeamName        : String
  , gameLength         : GameLength
  }


type Event = A | B

type alias Data =
  { blueTeam          : Team
  , redTeam           : Team
  }

type alias Team =
  { teamStates        : Array TeamState
  , players           : Array Player
  }

type alias TeamState =
  { dragons           : Int
  , barons            : Int
  , turrets           : Int
  }

type alias Player =
  { id                : PlayerId
  , role              : Role
  , ign               : Ign
  , championName      : Name
  , championImage     : Image
  , state             : Array PlayerState
  , participantId     : ParticipantId
  }

type alias PlayerState =
  { position          : Position
  , championState     : ChampionState
  , kills             : Int
  , deaths            : Int
  , assists           : Int
  , currentGold       : Float
  , totalGold         : Float
  }

type alias Position =
  { x                 : Float
  , y                 : Float
  }

type alias ChampionState =
  { hp                : Float
  , hpMax             : Float
  , power             : Float
  , powerMax          : Float
  , xp                : Xp
  }

type Role = Top | Jungle | Mid | Bot | Support
type Side = Red | Blue

getTeamName : Side -> Metadata -> String
getTeamName side =
  case side of
    Blue -> .blueTeamName
    Red -> .redTeamName

getTeam : Side -> Data -> Team
getTeam side =
  case side of
    Blue -> .blueTeam
    Red -> .redTeam

type alias Level = Int
type alias Xp = Float

getCurrentLevel : Xp -> Level
getCurrentLevel xp = -- This is a derived formula
  min 18 << truncate <| (sqrt (2 * xp + 529) - 13) / 10

getXpToNextLevel : Xp -> Xp
getXpToNextLevel xp =
  getXpRequiredForLevel (getCurrentLevel xp + 1) - xp

getXpRequiredForLevel : Level -> Xp
getXpRequiredForLevel level =
  if level > 18
  then 0
  else toFloat <| 10 * (level - 1) * (18 + 5 * level)

