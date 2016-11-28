module TagForm.Internal.Update exposing (..)

import Http exposing (Body, RawError, Request, Response, defaultSettings, empty, multipart, stringData)
import String exposing (toInt)
import TagForm.Internal.Save exposing (sendRequest)
import TagForm.Types exposing (..)
import TagForm.Types exposing(Model)
import Task
import Timeline.Types as TimelineT
import Types exposing (WindowLocation)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
   CreateTitle title ->
    ({model | title = title }, Cmd.none)
   CreateDescription description ->
    ({model | description = description}, Cmd.none)
   CreateCategory category ->
    ({model | category = category}, Cmd.none)
   AddPlayers ign ->
    ({model | players = ign }, Cmd.none)
   CancelForm ->  -- TODO: should hide the form
    (model, Cmd.none)
   SaveTag ->
    (model, Cmd.none)

