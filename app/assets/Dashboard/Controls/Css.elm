module Controls.Css exposing (..)

import Css exposing (..)
import Css.Namespace
import CssColors as Color
import DashboardCss
import StyleUtils

-- Variables for Timeline appearance
-- All of these values are pixel equivalents
namespace = "controls"

controlsWidth : Float
controlsWidth = 512

controlsHeight : Float
controlsHeight = 60

buttonWidth : Float
buttonWidth = controlsHeight

timelineWidth : Float
timelineWidth = controlsWidth - DashboardCss.dividerWidth - buttonWidth

barHeight : Float
barHeight = 7

knobHeight : Float
knobHeight = 12

knobWidth : Float
knobWidth = 1

knobBottom : Float
knobBottom = (controlsHeight - barHeight) / 2

type CssClass
  = Bar
  | BarSeen
  | Controls
  | Hidden
  | Knob
  | PlayButton
  | PlayPauseImg
  | TimeDisplay
  | Timeline
  | TimelineAndDisplay

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
      [ (.) TimelineAndDisplay (
        [ displayFlex
        , position relative
        , height (100 |> pct)
        ] ++ StyleUtils.flexDirection "column" ++
        [ property "justify-content" "space-between"
        , alignItems flexEnd
        , children
          [ (.) Timeline
            [ position relative
            , height (barHeight |> px)
            , width (timelineWidth |> px)
            , backgroundColor Color.c_lightGray
            , textAlign right
            , children
              [ (.) BarSeen
                [ property "pointer-events" "none"
                , backgroundColor Color.c_darkGray
                , height (100 |> pct)
                ]
              ]
            ]
          , (.) TimeDisplay
            [ color Color.c_white
            , withClass Hidden
              [ property "visibility" "hidden"
              ]
            ]
          , (.) Knob
            [ position absolute
            , bottom (knobBottom |> px)
            , left zero
            , width (knobWidth |> px)
            , height (knobHeight |> px)
            , backgroundColor Color.c_darkGray
            , transform << translateX << pct <| -50
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
    ])
  ]