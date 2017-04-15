module Dashboard exposing (..)

import Array
import Controls.Controls as Controls
import GameModel exposing (Data, Metadata)
import Minimap.Minimap as Minimap
import Navigation exposing (Location)
import Populate
import Subscriptions
import TagCarousel.TagCarousel as TagCarousel
import Types exposing (..)
import Update
import View
import Minimap.Minimap as Minimap
import TagCarousel.TagCarousel as TagCarousel
import PlayerDisplay.PlayerDisplay as PlayerDisplay
import Graph.Graph as Graph

init : Flags -> Location -> (Model, Cmd Msg)
init flags location =
  let
    minimapModel = Minimap.init flags
    (tagCarouselModel, tagCarouselCmd)
      = TagCarousel.init location flags.addTagButton flags.deleteTagButton flags.editTagButton
    controlsModel = Controls.init flags.playButton flags.pauseButton

    teamDisplay =
      { airDragonIcon = flags.airDragonIcon
      , earthDragonIcon = flags.earthDragonIcon
      , fireDragonIcon  = flags.fireDragonIcon
      , waterDragonIcon = flags.waterDragonIcon
      , elderDragonIcon = flags.elderDragonIcon
      }
    metadata : Metadata
    metadata =
      { blueTeamName = ""
      , redTeamName = ""
      , gameLength = 100
      }
    data : Data
    data =
      { blueTeam =
        { teamStates = Array.empty
        , players = Array.empty
        }
      , redTeam =
        { teamStates = Array.empty
        , players = Array.empty
        }
      }
  in
    { minimap = minimapModel
    , tagCarousel = tagCarouselModel
    , controls = controlsModel
    , game =
      { metadata = metadata
      , data = data
      }
    , timestamp = 0
    , viewType = Map
    , playerDisplay = PlayerDisplay.init
    , graphStat = Graph.init
    , currentUser = Nothing
    , permissions = []
    , loadingIcon = flags.loadingIcon
    , events = []
    , teamDisplay = teamDisplay
    , pathLength = 0
    } !
    [ Cmd.map TagCarouselMsg tagCarouselCmd
    , Populate.populate location
    ]

main : Program Flags Model Msg
main =
  Navigation.programWithFlags
    LocationUpdate
    { init = init
    , view = View.view
    , update = Update.update
    , subscriptions = Subscriptions.subscriptions
    }
