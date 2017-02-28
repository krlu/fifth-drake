module Graph.Internal.Update exposing (..)

import Graph.Types exposing (Model, Msg(ChangeStat, PlotInteraction), Stat(Gold, HP, XP))
import Plot exposing (Interaction(Custom, Internal))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ChangeStat stat ->
      case stat of
        "XP" -> ( {model | selectedStat = XP}, Cmd.none)
        "Gold" -> ( {model | selectedStat = Gold}, Cmd.none)
        "HP" -> ({model | selectedStat = HP}, Cmd.none)
        _ ->  (model, Cmd.none)
    PlotInteraction interaction ->
        case interaction of
            Internal internalMsg ->
                ({ model | plotState = Plot.update internalMsg model.plotState }, Cmd.none)
            Custom yourMsg -> (model, Cmd.none)
