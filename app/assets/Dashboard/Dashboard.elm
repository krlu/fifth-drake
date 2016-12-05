module Dashboard exposing (..)

import Array
import Controls.Controls as Controls
import GameModel exposing (Data, GameId, Metadata)
import Minimap.Minimap as Minimap
import Navigation exposing (Location)
import Populate
import Subscriptions
import TagScroller.TagScroller as TagScroller
import Types exposing (..)
import Update
import View

init : Flags -> Location -> (Model, Cmd Msg)
init flags location =
  let
    minimapModel = Minimap.init flags.minimapBackground
    (tagScrollerModel, tagScrollerCmd) = TagScroller.init location
    controlsModel = Controls.init flags.playButton flags.pauseButton
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
    , tagScroller = tagScrollerModel
    , controls = controlsModel
    , game =
      { metadata = metadata
      , data = data
      }
    , timestamp = 0
    } !
    [ Cmd.map TagScrollerMsg tagScrollerCmd
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
