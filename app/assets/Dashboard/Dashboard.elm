module Dashboard exposing (..)

import Array
import GameModel exposing (GameData)
import Html.App
import Minimap.Minimap as Minimap
import Subscriptions
import Populate
import TagScroller.TagScroller as TagScroller
import Timeline.Timeline as Timeline
import Types exposing (..)
import Update
import View

init : Flags -> (Model, Cmd Msg)
init flags =
  let
    minimapModel = Minimap.init flags.minimapBackground
    (tagScrollerModel, tagScrollerCmd) = TagScroller.init flags.location
    timelineModel = Timeline.init flags
    gameDataModel : GameData
    gameDataModel =
      { blueTeam =
        { teamStates = Array.empty
        , playerStates = Array.empty
        }
      , redTeam =
        { teamStates = Array.empty
        , playerStates = Array.empty
        }
      }
  in
    { minimap = minimapModel
    , tagScroller = tagScrollerModel
    , timeline = timelineModel
    , gameData = gameDataModel
    , gameLength = 100
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
