module Update exposing (..)

import Messages exposing (Msg(..))
import Models exposing (Model)
import Timeline.Update as TUpdate
import Minimap.Update as MUpdate

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
    dispatch msgMap modelMap update' msg submodel =
      let
        (subModel, subCmds) = update' msg submodel
      in
        ( modelMap subModel
        , Cmd.map msgMap subCmds
        )
  in
    case msg of
      TimelineMsg m ->
        let
          modelMap subModel = { model | timeline = subModel }
        in
          dispatch TimelineMsg modelMap TUpdate.update m model.timeline
      MinimapMsg m ->
        let
          modelMap subModel = { model | minimap = subModel }
        in
          dispatch MinimapMsg modelMap MUpdate.update m model.minimap
