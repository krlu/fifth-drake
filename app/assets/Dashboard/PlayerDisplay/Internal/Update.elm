module PlayerDisplay.Internal.Update exposing (..)

import PlayerDisplay.Types exposing (Model, Msg(..))
import Set

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    PlotInteraction plotMsg -> (model, Cmd.none)
    PlayerDisplayClicked id ->
     let
      newSet =
        case Set.member id model.selectedPlayers of
            True -> Set.remove id model.selectedPlayers
            False -> Set.insert id model.selectedPlayers
     in
      ( {model | selectedPlayers = newSet}, Cmd.none)
    PlayerDisplayHovered playerId -> ({ model | hoveredPlayer = Just playerId }, Cmd.none)
    PlayerDisplayUnhovered -> ({ model | hoveredPlayer = Nothing }, Cmd.none)

