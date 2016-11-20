module Timeline.Css exposing (..)

import Css exposing (..)
import Css.Namespace
import DashboardCss
import StyleUtils

-- Variables for Timeline appearance
-- All of these values are pixel equivalents
namespace = "timeline"

controlsWidth : Float
controlsWidth = 512

controlsHeight : Float
controlsHeight = 40

knobWidth : Float
knobWidth = 10

buttonWidth : Float
buttonWidth = controlsHeight

timelineWidth : Float
timelineWidth = controlsWidth - DashboardCss.dividerWidth - buttonWidth

type CssClass
  = Controls
  | Timeline
  | Bar
  | Knob
  | PlayButton
  | PlayPauseImg

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) Controls (
    [ displayFlex
    , height (controlsHeight |> px)
    , width (controlsWidth |> px)
    ] ++
    StyleUtils.userSelect "none" ++
    [ children
      [ (.) Timeline
        [ position relative
        , height (100 |> pct)
        , width (timelineWidth |> px)
        , children
          [ (.) Bar
            [ position relative
            , height (100 |> pct)
            , backgroundColor (hex "#FF0000")
            ]
          , (.) Knob
            [ position absolute
            , top zero
            , left zero
            , width (knobWidth |> px)
            , height (100 |> pct)
            , backgroundColor (hex "#0000FF")
            , transform << translateX << pct <| -50
            ]
          ]
        ]
      ]
    ])
  , (.) PlayButton
    [ height (100 |> pct)
    , width (buttonWidth |> px)
    , children
      [ (.) PlayPauseImg
        [ height (100 |> pct)
        , width (100 |> pct)
        ]
      ]
    ]
  ]