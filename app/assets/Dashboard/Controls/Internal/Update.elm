module Controls.Internal.Update exposing (update)

import Controls.Internal.ModelUtils exposing(..)
import Controls.Types exposing (..)
import GameModel exposing (..)
import Mouse
import Types exposing (TimeSelection(..))

update : TimeSelection -> GameLength -> Msg -> Model -> (TimeSelection, Model)
update selection gameLength msg ({mouse} as model) =
  case msg of
    KnobGrab pos ->
      ( selection
      , { model | mouse = Just <| Drag pos pos }
      )
    KnobMove pos ->
      ( selection
      , { model | mouse = Maybe.map (\{start} -> Drag start pos) mouse }
      )
    KnobRelease pos ->
      ( getUpdatedSelection selection gameLength model
      , { model | mouse = Nothing }
      )
    BarClick (pos, rel) ->
      ( updateSelection gameLength rel
      , { model | mouse = Just <| Drag pos pos }
      )
    PlayPause ->
      ( selection
      , { model | status = toggleStatus model.status }
      )
    TimerUpdate _ -> (
      case selection of
        Instant timestamp ->
          if timestamp >= gameLength then
            ( Instant timestamp
            , { model | status = Pause }
            )
          else
            ( Instant (timestamp + 1)
            , model
            )
        Range (start, end) ->
          Debug.crash "Unimplmented"
      )
    UseSecondKnob b ->
      Debug.log "Add timeselection thing here"
      (selection, model)

updateSelection : GameLength -> Mouse.Position -> TimeSelection
updateSelection gameLength rel =
  Instant <| getTimestampAtPixel gameLength rel

getUpdatedSelection : TimeSelection -> GameLength -> Model -> TimeSelection
getUpdatedSelection selection gameLength model =
  case selection of
    Instant timestamp ->
      Instant <| getTimestampAtMouse model.mouse timestamp gameLength
    Range (start, end) ->
      Debug.crash "Unimplemented"
