module Minimap.Css exposing (..)

import Css exposing (..)
import Css.Namespace
import CssColors exposing (c_redTeam, c_blueTeam)
import GameModel exposing (Side(Blue, Red))
import StyleUtils

namespace : String
namespace = "minimap"

minimapHeight : Float
minimapHeight = 512

minimapWidth : Float
minimapWidth = 512

playerIconSize : Float
playerIconSize = 30

iconBorderWidth : Float
iconBorderWidth = 2.5

type CssClass
  = Minimap
  | PlayerIcon
  | IconColor Side
  | Background
  | ChampionImage
  | HighlightedIconColor

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ class Minimap (
    [ position relative
    , height (minimapHeight |> px)
    , width (minimapWidth |> px)
    ] ++
    StyleUtils.userSelect "none" ++
    [ children
      [ class PlayerIcon
        [ position absolute
        , zIndex (2 |> int)
        , width (playerIconSize |> px)
        , height (playerIconSize |> px)
        , transform <| translate2 (-50 |> pct) (50 |> pct)
        , border2 (iconBorderWidth |> px) solid
        , borderRadius (50 |> pct)
        , withClass (IconColor Blue)
          [ borderColor CssColors.c_blueTeam
          ]
        , withClass (IconColor Red)
          [ borderColor CssColors.c_redTeam
          ]
        , withClass HighlightedIconColor
          [ borderColor CssColors.c_highlighted_player
          , property "border-width" "4px"
          , zIndex (10 |> int)
          ]
        , backgroundSize cover
        , children
          [ class ChampionImage
            [ width (100 |> pct)
            , height (100 |> pct)
            , borderRadius (50 |> pct)
            ]
          ]
        ]
      , class Background
        [ height (100 |> pct)
        , width (100 |> pct)
        ]
      ]
    ])
  ]

