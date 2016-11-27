module Update exposing (..)

import Minimap.Minimap as Minimap
import Minimap.Types as MinimapT
import TagScroller.TagScroller as TagScroller
import TagScroller.Types as TagScrollerT
import Timeline.Timeline as Timeline
import Timeline.Types as TimelineT
import Types exposing (..)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
    dispatch : (subMsg -> Msg) ->
               (subModel -> Model) ->
               (subMsg -> subModel ->
               (subModel, Cmd subMsg)) ->
               subMsg ->
               subModel ->
               (Model, Cmd Msg)
    dispatch msgMap modelMap update' msg submodel =
      let
        (subModel, subCmds) = update' msg submodel
      in
        ( modelMap subModel
        , Cmd.map msgMap subCmds
        )

    timelineModelMap origModel subModel = { origModel | timeline = subModel }
    minimapModelMap origModel subModel = { origModel | minimap = subModel }
    tagModelMap origModel subModel = { origModel | tagScroller = subModel }
    --added this too
    gameData origModel subModel = { origModel | gameData = subModel }
  in
    case msg of
      TimelineMsg m ->
        let
          (model', cmds) = dispatch TimelineMsg (timelineModelMap model) Timeline.update m model.timeline
          (model'', cmds') = update (MinimapMsg << MinimapT.UpdateTimestamp <| model'.timeline.value) model'
        in
          model'' ! [cmds, cmds']
      MinimapMsg m ->
        dispatch MinimapMsg (minimapModelMap model) Minimap.update m model.minimap
      TagScrollerMsg (TagScrollerT.TagClick value as m) ->
        let
          (model', cmds) = dispatch TagScrollerMsg (tagModelMap model) TagScroller.update m model.tagScroller
          (model'', cmds') = update (TimelineMsg << TimelineT.SetValue <| value) model'
        in
          model'' ! [cmds, cmds']
      TagScrollerMsg m ->
        dispatch TagScrollerMsg (tagModelMap model) TagScroller.update m model.tagScroller
    --added SetGameData
      SetGameData m ->
        dispatch SetGameData (gameData model) update m model.gameData