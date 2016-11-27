module Dashboard exposing (..)

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
    (minimapModel, minimapCmd) = Minimap.init flags.minimapBackground flags.location
    (tagScrollerModel, tagScrollerCmd) = TagScroller.init flags.location
    (timelineModel, timelineCmd) = Timeline.init flags
    --added setGameData
    (gameDataModel, setGameDataCmd) = GameData
  in
    { minimap = minimapModel
    , gameData = gameDataModel
    , tagScroller = tagScrollerModel
    , timeline = timelineModel
    } !
    [ Cmd.map MinimapMsg minimapCmd
    --added setGameData
    , Cmd.map SetGameData setGameDataCmd
    , Cmd.map TagScrollerMsg tagScrollerCmd
    , Cmd.map TimelineMsg timelineCmd
    ]

main : Program Flags
main =
  Html.App.programWithFlags
    { init = init
    , view = View.view
    , update = Update.update
    , subscriptions = Subscriptions.subscriptions
    }
