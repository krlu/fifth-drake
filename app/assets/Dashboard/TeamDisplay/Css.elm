module TeamDisplay.Css exposing (..)

import Css exposing (..)
import Css.Elements exposing (h1, p, span)
import Css.Namespace
import CssColors as Color
import Color
import GameModel exposing (Side(..))
import StyleUtils

namespace = "team-display"

teamNameSize : Float
teamNameSize = 48

displayWidth : Float
displayWidth = 300

displayHeight : Float
displayHeight = 125

type CssClass
  = TeamDisplay
  | ColorClass Side
  | TeamStats
  | Label

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) TeamDisplay (
    [ displayFlex
    , alignItems center
    , property "justify-content" "space-around"
    ] ++ StyleUtils.flexDirection "column" ++
    [ backgroundColor (hex "#3b4047")
    , width (displayWidth |> px)
    , height (displayHeight |> px)
    , borderBottom2 (3 |> px) solid
    , borderBottomLeftRadius (3 |> px)
    , borderBottomRightRadius (3 |> px)
    , children
      [ h1
        [ fontSize (teamNameSize |> px)
        ]
      , (.) TeamStats (
        [ displayFlex
        , property "justify-content" "space-around"
        , width (100 |> pct)
        ] ++ StyleUtils.flexDirection "row" ++
        [ children
          [ p
            [ color Color.c_offWhite
            , children
              [ span
                [ color Color.c_teamStatLabels
                ]
              ]
            ]
          ]
        ]
        )
      ]
    ])
  , (.) (ColorClass Blue)
    [ color Color.c_blueTeam
    , borderColor Color.c_blueTeam
    ]
  , (.) (ColorClass Red)
    [ color Color.c_redTeam
    , borderColor Color.c_redTeam
    ]
  ]
