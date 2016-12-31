module Update exposing (..)

import Array exposing (Array)
import Controls.Controls as Controls
import Controls.Types as ControlsT
import GameModel exposing (Player)
import Minimap.Minimap as Minimap
import Minimap.Types as MinimapT
import TagCarousel.TagCarousel as TagCarousel
import TagCarousel.Types as TagCarouselT
import Types exposing (..)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    TagCarouselMsg tmsg ->
      let
        (timestamp, tmodel, cmd) = TagCarousel.update tmsg model.tagCarousel model.timestamp
      in
        ( { model | tagCarousel = tmodel
                  , timestamp = Maybe.withDefault model.timestamp timestamp
                  , minimap = Minimap.update model.minimap model.game.data model.timestamp MinimapT.SnapIconStates
          }
        , Cmd.map TagCarouselMsg cmd
        )
    ControlsMsg cmsg ->
      -- create tuple for functions that need to be run depending on what controls callback occurred
      -- setFunction will allow icons to snap to a location, whereas increment will have icons animation to a location
      let
        (snapFunction , incrementFunction) =
          ( let
              (timestamp, cmodel) =
                Controls.update model.timestamp model.game.metadata.gameLength cmsg model.controls
            in
              ( { model | timestamp = timestamp
                        , controls = cmodel
                        , minimap = Minimap.update model.minimap model.game.data model.timestamp MinimapT.SnapIconStates
                }
              , Cmd.none
              )
          , let
              (timestamp, cmodel) =
                Controls.update model.timestamp model.game.metadata.gameLength cmsg model.controls
            in
              ( { model | timestamp = timestamp
                        , controls = cmodel
                        , minimap = Minimap.update model.minimap model.game.data model.timestamp MinimapT.IncrementIconStates
                }
              , Cmd.none
              )
          )
      in
        case cmsg of
          ControlsT.TimerUpdate _ ->
            incrementFunction
          ControlsT.BarClick _ ->
            snapFunction
          ControlsT.KnobMove _ ->
            snapFunction
          ControlsT.KnobRelease _ ->
            snapFunction
          _ ->
            incrementFunction
    MinimapMsg mmsg ->
      let
        mmodel =
          Minimap.update model.minimap model.game.data model.timestamp mmsg
      in
        ( { model | minimap = mmodel
          }
        , Cmd.none
        )
    SetGame (Ok game) ->
      ( { model | game = game
                , minimap =  Minimap.update model.minimap game.data model.timestamp MinimapT.GenerateIconStates
        }
      , Cmd.none
      )
    SetGame (Err err) ->
      Debug.log "Game Data failed to fetch" (model, Cmd.none)
    LocationUpdate loc -> (model, Cmd.none)
