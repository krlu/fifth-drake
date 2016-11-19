module Timeline.Css exposing (..)

import Css exposing (..)
import Css.Namespace
import StyleUtils

-- Variables for Timeline appearance
-- All of these values are pixel equivalents
namespace = "timeline"

timelineWidth : Float
timelineWidth = 512

timelineHeight : Float
timelineHeight = 40

knobWidth : Float
knobWidth = 10

buttonWidth : Float
buttonWidth = timelineHeight

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
    , height (timelineHeight |> px)
    , width (timelineWidth |> px)
    ] ++
    StyleUtils.userSelect "none" ++
    [ children
      [ (.) Timeline
        [ position relative
        , height (100 |> pct)
        , width (100 |> pct)
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