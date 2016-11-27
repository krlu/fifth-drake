module Timeline.Css exposing (..)

import Css exposing (..)
import Css.Namespace
import CssColors as Color
import DashboardCss
import StyleUtils

-- Variables for Timeline appearance
-- All of these values are pixel equivalents
namespace = "timeline"

controlsWidth : Float
controlsWidth = 512

controlsHeight : Float
controlsHeight = 60

knobWidth : Float
knobWidth = 3

buttonWidth : Float
buttonWidth = controlsHeight

timelineHeight : Float
timelineHeight = 10

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
    StyleUtils.flexDirection "row" ++
    StyleUtils.userSelect "none" ++
    [ alignItems center
    , children
      [ (.) Timeline
        [ position relative
        , height (timelineHeight |> px)
        , width (timelineWidth |> px)
        , children
          [ (.) Bar
            [ position relative
            , height (100 |> pct)
            , backgroundColor Color.c_lighterGray
            ]
          , (.) Knob
            [ position absolute
            , top zero
            , left zero
            , width (knobWidth |> px)
            , height (100 |> pct)
            , backgroundColor Color.c_darkGray
            , transform << translateX << pct <| -50
            ]
          ]
        ]
      ]
    ])
  , (.) PlayButton
    [ height (100 |> pct)
    , property "border" "none"
    , property "background" "none"
    , padding zero
    , width (buttonWidth |> px)
    , children
      [ (.) PlayPauseImg
        [ height (100 |> pct)
        , width (100 |> pct)
        ]
      ]
    ]
  ]