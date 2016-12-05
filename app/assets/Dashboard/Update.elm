module Update exposing (..)

import Controls.Controls as Controls
import Controls.Types as TimelineT
import Minimap.Minimap as Minimap
import Minimap.Types as MinimapT
import TagScroller.TagScroller as TagScroller
import TagScroller.Types as TagScrollerT
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
    ControlsMsg tmsg ->
      let
        (timestamp, cmodel) =
          Controls.update model.timestamp model.game.metadata.gameLength tmsg model.controls
      in
        ( { model | timestamp = timestamp
                  , controls = cmodel
          }
        , Cmd.none
        )
    SetGame (Ok game) ->
      ({ model | game = game }, Cmd.none)
    SetGame (Err err) ->
      Debug.log "Game Data failed to fetch" (model, Cmd.none)
    UpdateTimestamp timestamp ->
      ( { model | timestamp = timestamp }
      , Cmd.none
      )
    LocationUpdate loc -> (model, Cmd.none)
