module PlayerDisplay.Types exposing (..)

import Plot

type Msg = PlotInteraction (Plot.Interaction Msg)
