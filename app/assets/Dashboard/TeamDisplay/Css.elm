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

statsFontSize : Float
statsFontSize = 14

teamDisplayWidth : Float
teamDisplayWidth = 275

teamDisplayContainerWidth : Float
teamDisplayContainerWidth = 450

teamDisplayHeight : Float
teamDisplayHeight = 100

type CssClass
  = TeamDisplay
  | TeamStats
  | Label
  | DragonImage
  | TeamDisplayContainer
  | DragonDisplay

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ class TeamDisplay (
    [ displayFlex
    , alignItems center
    , justifyContent spaceAround
    ] ++ StyleUtils.flexDirection "column" ++
    [ width (teamDisplayWidth |> px)
    , height (teamDisplayHeight |> px)
    , overflow hidden
    , children
      [ h1
        [ fontSize (teamNameSize |> px)
        , whiteSpace noWrap
        ]
      , class TeamStats (
        [ displayFlex
        , justifyContent spaceAround
        , width (100 |> pct)
        ] ++ StyleUtils.flexDirection "row" ++
        [ children
          [ p
            [ color Color.c_offWhite
            , flex (int 1)
            , textAlign center
            , fontSize (statsFontSize |> px)
            , children
              [ span
                [ color Color.c_teamStatLabels
                , textTransform uppercase
                ]
              ]
            ]
          ]
        ]
        )
      ]
    ])
  , class DragonImage
    [ width (2 |> vw)
    , height (3 |> vh)
    , borderRadius (3 |> vh)
    , position relative
    , top (68 |> px)
    ]
  , class TeamDisplayContainer
    [ width (teamDisplayContainerWidth |> px)
    , displayFlex
    ]
  , class DragonDisplay
    [ displayFlex
    , width (200 |> px)
    ]
  ]
