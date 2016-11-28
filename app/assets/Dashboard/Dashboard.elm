module Dashboard exposing (..)

import GameModel exposing (GameData)
import Html.App
import Subscriptions
import Types exposing (..)
import Update
import View
import Timeline.Timeline as Timeline
import Minimap.Minimap as Minimap
import TagScroller.TagScroller as TagScroller

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
