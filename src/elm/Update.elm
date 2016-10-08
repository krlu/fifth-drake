module Update exposing (..)

import Messages exposing (Msg(..))
import Minimap.Messages as MMsg
import Minimap.Models as MModel
import Minimap.Update as MUpdate
import Models exposing (Model)
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
  in
    case msg of
      TimelineMsg m ->
        let
          (model', cmds) =
            dispatch
              TimelineMsg
              (tModelMap model)
              TUpdate.update
              m
              model.timeline
          (model'', cmds') =
            dispatch
              MinimapMsg
              (mModelMap model')
              MUpdate.update
              (MMsg.UpdateTimestamp model'.timeline.value)
              model.minimap
        in
            model'' ! [cmds, cmds']
      MinimapMsg m ->
        dispatch MinimapMsg (mModelMap model) MUpdate.update m model.minimap
