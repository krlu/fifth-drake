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
  case msg of
    TagScrollerMsg tmsg ->
      let
        (timestamp, tmodel) = TagScroller.update tmsg model.tagScroller
      in
        ( { model | tagScroller = tmodel
                  , timestamp = Maybe.withDefault model.timestamp timestamp
          }
        , Cmd.none
        )
    TimelineMsg tmsg ->
      let
        (timestamp, tmodel) =
          Timeline.update model.timestamp model.gameLength tmsg model.timeline
      in
        ( { model | timestamp = timestamp
                  , timeline = tmodel
          }
        , Cmd.none
        )
    SetGameData gameData ->
      ({ model | gameData = gameData }, Cmd.none)
    GameDataFetchFailure err ->
      Debug.log "Game Data failed to fetch" (model, Cmd.none)
    UpdateTimestamp timestamp ->
      ( { model | timestamp = timestamp }
      , Cmd.none
      )