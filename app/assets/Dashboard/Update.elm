module Update exposing (..)

import Array exposing (Array)
import Controls.Controls as Controls
import Controls.Types as TimelineT
import GameModel exposing (Player)
import Minimap.Minimap as Minimap
import Minimap.Types as MinimapT
import TagCarousel.TagCarousel as TagCarousel
import TagCarousel.Types as TagCarouselT
import Types exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TagCarouselMsg tmsg ->
            let
                ( timestamp, tmodel, cmd ) =
                    TagCarousel.update tmsg model.tagCarousel model.timestamp
            in
                ( { model
                    | tagCarousel = tmodel
                    , timestamp = Maybe.withDefault model.timestamp timestamp
                  }
                , Cmd.map TagCarouselMsg cmd
                )

        ControlsMsg tmsg ->
            let
                ( timestamp, cmodel ) =
                    Controls.update model.timestamp model.game.metadata.gameLength tmsg model.controls
            in
                ( { model
                    | timestamp = timestamp
                    , controls = cmodel
                  }
                , Cmd.none
                )

        SetGame (Ok game) ->
            ( { model | game = game }, Cmd.none )

        SetGame (Err err) ->
            Debug.log "Game Data failed to fetch" ( model, Cmd.none )

        UpdateTimestamp timestamp ->
            ( { model | timestamp = timestamp }
            , Cmd.none
            )

        LocationUpdate loc ->
            ( model, Cmd.none )
