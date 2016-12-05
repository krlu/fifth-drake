module Dashboard exposing (..)

import Array
import Controls.Controls as Controls
import GameModel exposing (Data, Metadata)
import Html
import Minimap.Minimap as Minimap
import Populate
import Subscriptions
import TagScroller.TagScroller as TagScroller
import Types exposing (..)
import Update
import View

init : Flags -> (Model, Cmd Msg)
init flags =
  let
    minimapModel = Minimap.init flags.minimapBackground
    (tagScrollerModel, tagScrollerCmd) = TagScroller.init flags.location
    controlsModel = Controls.init flags
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
    , Populate.populate flags.location
    ]

main : Program Flags Model Msg
main =
  Html.programWithFlags
    { init = init
    , view = View.view
    , update = Update.update
    , subscriptions = Subscriptions.subscriptions
    }
