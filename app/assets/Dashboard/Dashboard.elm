module Dashboard exposing (..)

import Array
import GameModel exposing (Data, Metadata)
import Html.App
import Minimap.Minimap as Minimap
import Subscriptions
import Populate
import TagScroller.TagScroller as TagScroller
import Timeline.Timeline as Timeline
import Types exposing (..)
import Update
import View
import Timeline.Timeline as Timeline
import Minimap.Minimap as Minimap
import TagScroller.TagScroller as TagScroller
import TagForm.TagForm as TagForm


init : Flags -> (Model, Cmd Msg)
init flags =
  let
    minimapModel = Minimap.init flags.minimapBackground
    (tagScrollerModel, tagScrollerCmd) = TagScroller.init flags.location
    (tagFormModel,tagFormCmd) = TagForm.init flags.location
    timelineModel = Timeline.init flags
    metadata : Metadata
    metadata =
      { gameLength = 100
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
    , timeline = timelineModel
    , tagForm = tagFormModel
    , game =
      { metadata = metadata
      , data = data
      }
    , timestamp = 0
    } !
    [ Cmd.map TagScrollerMsg tagScrollerCmd
    , Populate.populate flags.location
    ]

main : Program Flags
main =
  Html.App.programWithFlags
    { init = init
    , view = View.view
    , update = Update.update
    , subscriptions = Subscriptions.subscriptions
    }
