module Update exposing (..)

import Array exposing (Array)
import Controls.Controls as Controls
import Controls.Types as ControlsT
import GameModel exposing (Player)
import Minimap.Minimap as Minimap
import Minimap.Types as MinimapT
import PlaybackTypes exposing (..)
import String exposing (toInt)
import TagCarousel.TagCarousel as TagCarousel
import TagCarousel.Types as TagCarouselT
import PlayerDisplay.PlayerDisplay as PlayerDisplay
import Graph.Graph as Graph
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
                  , minimap = Minimap.update model.minimap model.game.data (Maybe.withDefault model.timestamp timestamp) (MinimapT.MoveIconStates Snap)
          }
        , Cmd.map TagCarouselMsg cmd
        )
    ControlsMsg cmsg ->
      let
        (timestamp, cmodel) =
          Controls.update model.timestamp model.game.metadata.gameLength cmsg model.controls
      in
        ( { model
          | timestamp = timestamp
          , controls = cmodel
          , minimap = Minimap.update model.minimap model.game.data model.timestamp (MinimapT.MoveIconStates Snap)
          }
        , Cmd.none
        )
    TimerUpdate _ ->
      let
        controlModel = model.controls
        --paused controls will be used when the game is over
        pausedControls =
          { controlModel
          | status = Pause
          }
      in
        if model.timestamp >= model.game.metadata.gameLength then
          ( { model
            | controls = pausedControls
            }
          , Cmd.none
          )
        else
          ( { model
            | timestamp = model.timestamp + 1
            , minimap =
                Minimap.update model.minimap model.game.data (model.timestamp) (MinimapT.MoveIconStates Increment)
            }
          , Cmd.none
          )
    MinimapMsg mmsg ->
      let
        mmodel =
          Minimap.update model.minimap model.game.data model.timestamp mmsg
      in
        ( { model | minimap = mmodel
          }
        , Cmd.none
        )
    SetData (Ok dashboardData) ->
      ( { model
        | game = dashboardData.game
        , minimap = Minimap.update model.minimap dashboardData.game.data model.timestamp MinimapT.GenerateIconStates
        , currentUser = Just dashboardData.currentUser
        , permissions = dashboardData.permissions
        , events = dashboardData.objectiveEvents
        }
      , Cmd.none
      )
    SetData (Err err) ->
      Debug.log "Game Data failed to fetch" (model, Cmd.none)
    LocationUpdate loc -> (model, Cmd.none)
    SwitchView ->
      let
        viewType =
          case model.viewType of
            Map -> Stats
            Stats -> Map
      in
        ({model | viewType = viewType}, Cmd.none)
    PlayerDisplayMsg msg ->
      let
        (pModel, cmd) = PlayerDisplay.update msg model.playerDisplay
      in
        ({model | playerDisplay = pModel}, Cmd.none)
    GraphMsg msg ->
      let
        (gModel, cmd) = Graph.update msg model.graphStat model.game.metadata.gameLength
      in
        ({model | graphStat = gModel}, Cmd.none)
    SetPathLength lengthString ->
      let
        length =
          case (toInt lengthString) of
            Ok len -> len
            Err msg -> Debug.log msg 0
      in
        ({model | pathLength = length }, Cmd.none)

