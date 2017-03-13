module Graph.Internal.Update exposing (update)

import GameModel exposing (GameLength)
import Graph.Types exposing (Model, Msg(ChangeStat, PlotInteraction, SubmitRange, UpdateEnd, UpdateStart), Stat(Gold, HP, XP))
import Plot exposing (Interaction(Custom, Internal))
import String exposing (toInt)

update : Msg -> Model -> GameLength -> (Model, Cmd Msg)
update msg model gameLength=
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
    UpdateStart start ->
      let
        startVal = extractVal start
        form = model.rangeForm
        newForm = { form | start = startVal }
      in
        ({model | rangeForm = newForm}, Cmd.none)
    UpdateEnd end ->
      let
        endVal = extractVal end
        form = model.rangeForm
        newForm = { form | end = endVal }
      in
        ({model | rangeForm = newForm}, Cmd.none)
    SubmitRange (start, end) ->
      if(end < start || end < 0 || start < 0 || start > gameLength || end > gameLength) then
        (model, Cmd.none)
      else
        ({model | start = start, end = end}, Cmd.none)

extractVal : String -> Int
extractVal string =
  case String.toInt string of
    Ok val -> val
    Err msg -> -1
