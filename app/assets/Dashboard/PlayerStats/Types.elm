module PlayerStats.Types exposing (..)

--Not sure what to put in the message

type Msg
  = SetData

type alias Model =
  { blueTeam : Team
  , redTeam  : Team
  }

type alias Team =
  { top     : PlayerItem
  , jungle  : PlayerItem
  , mid     : PlayerItem
  , bot     : PlayerItem
  , support : PlayerItem
  }

type alias PlayerItem =
  { playerName    : String
  , championIcon  : String
  , hpTracker     : ValueTracker
  , mpTracker     : ValueTracker
  , xpTracker     : ValueTracker
  }

type alias ValueTracker =
  { maxValue      : Float
  , currentValue  : Float
  }