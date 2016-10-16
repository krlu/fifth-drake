module Update exposing (..)

import Messages exposing (Msg(..))
import Minimap.Messages as MMsg
import Minimap.Models as MModel
import Minimap.Update as MUpdate
import Models exposing (Model)
import TagScroller.Messages as TagMsg
import TagScroller.Update as TagUpdate
import Timeline.Messages as TMsg
import Timeline.Models as TModel exposing (getCurrentValue)
import Timeline.Update as TUpdate

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

    tModelMap origModel subModel = { origModel | timeline = subModel }
    mModelMap origModel subModel = { origModel | minimap = subModel }
    tagModelMap origModel subModel = { origModel | tagScroller = subModel }
  in
    case msg of
      TimelineMsg m ->
        let
          (model', cmds) = dispatch TimelineMsg (tModelMap model) TUpdate.update m model.timeline
          (model'', cmds') = update (MinimapMsg << MMsg.UpdateTimestamp <| model'.timeline.value) model'
        in
          model'' ! [cmds, cmds']
      MinimapMsg m ->
        dispatch MinimapMsg (mModelMap model) MUpdate.update m model.minimap
      TagScrollerMsg (TagMsg.TagClick value as m) ->
        let
          (model', cmds) = dispatch TagScrollerMsg (tagModelMap model) TagUpdate.update m model.tagScroller
          (model'', cmds') = update (TimelineMsg << TMsg.SetValue <| value) model'
        in
          model'' ! [cmds, cmds']
      TagScrollerMsg m ->
        dispatch TagScrollerMsg (tagModelMap model) TagUpdate.update m model.tagScroller
