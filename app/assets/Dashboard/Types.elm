module Types exposing (..)

import Controls.Types as Controls
import GameModel exposing (Game, GameLength, PlayerId, Position, Timestamp)
import Http
import Minimap.Types as Minimap
import Navigation exposing (Location)
import Set exposing (Set)
import SettingsTypes exposing (GroupId, PermissionLevel, User, UserId)
import TagCarousel.Types as TagCarousel
import PlayerDisplay.Types as PlayerDisplay
import TeamDisplay.Types as TeamDisplay
import Graph.Types as Graph
import Time


type Msg
  = TagCarouselMsg TagCarousel.Msg
  | ControlsMsg Controls.Msg
  | TimerUpdate Time.Time
  | MinimapMsg Minimap.Msg
  | SetData (Result Http.Error DashboardData)
  | LocationUpdate Location
  | SwitchView
  | PlayerDisplayMsg PlayerDisplay.Msg
  | GraphMsg Graph.Msg
  | SetPathLength String

type alias Model =
  { controls : Controls.Model
  , minimap : Minimap.Model
  , tagCarousel : TagCarousel.Model
  , game : Game
  , timestamp : Timestamp
  , viewType : ViewType
  , playerDisplay : PlayerDisplay.Model
  , graphStat : Graph.Model
  , currentUser : Maybe User
  , permissions : List Permission
  , loadingIcon : String
  , events : List ObjectiveEvent
  , teamDisplay : TeamDisplay.Model
  , pathLength  : Int
  }

type alias ParticipantId = Int

type alias ObjectiveEvent =
  { unitKilled : String
  , killerId : ParticipantId
  , timestamp : Timestamp
  , position : Position
  }

type alias Permission =
  { groupId : GroupId
  , level : PermissionLevel
  }

type alias DashboardData =
  { game : Game
  , currentUser : User
  , permissions : List Permission
  , objectiveEvents : List ObjectiveEvent
  }

type alias Flags =
  { minimapBackground : String
  , playButton        : String
  , pauseButton       : String
  , addTagButton      : String
  , deleteTagButton   : String
  , editTagButton     : String
  , loadingIcon       : String
  , airDragonIcon     : String
  , earthDragonIcon   : String
  , fireDragonIcon    : String
  , waterDragonIcon   : String
  , elderDragonIcon   : String
  , blueTowerKillIcon : String
  , redTowerKillIcon  : String
  , blueTowerIcon     : String
  , redTowerIcon      : String
  , blueInhibitorKillIcon : String
  , redInhibitorKillIcon  : String
  , blueInhibitorIcon : String
  , redInhibitorIcon  : String
  }

type ViewType = Map | Stats

type TimeSelection
  = Instant Timestamp
  | Range (Timestamp, Timestamp)
