module PlayerDisplay.Css exposing (..)

import Css exposing (..)
import Css.Elements exposing (p)
import Css.Namespace
import CssColors as Color
import GameModel exposing (Side)
import StyleUtils

namespace : String
namespace = "playerDisplay"

playerDisplayWidth = 300
playerDisplayHeight = 100

playerIgnFontSize = 16

levelHeight = 30
levelWidth = levelHeight
levelFontSize = 18

portraitHeight = 60
portraitWidth = portraitHeight

champStatsWidth = 100
champStatsHeight = portraitHeight

champStatHeight = 7

type CssClass
  = PlayerDisplay
  | ChampDisplay
  | ChampPortrait
  | ChampStat
  | ChampStats
  | CurrentHp
  | CurrentPower
  | CurrentXp
  | Kda
  | PlayerIgn
  | PlayerLevel
  | PlayerStats

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) PlayerDisplay (
    [ displayFlex
    , width (playerDisplayWidth |> px)
    , height (playerDisplayHeight |> px)
    , padding (10 |> px)
    , property "justify-content" "space-between"
    , alignItems flexStart
    ] ++ StyleUtils.flexDirection "row" ++
    [ children
      [ (.) ChampDisplay (
        displayFlex
        :: StyleUtils.flexDirection "row" ++
        [ property "justify-content" "flex-start"
        , alignItems center
        , children
          [ (.) PlayerLevel
            [ backgroundColor Color.c_darkerGray
            , color Color.c_offWhite
            , height (levelHeight |> px)
            , width (levelWidth |> px)
            , borderRadius (50 |> pct)
            , fontSize (levelFontSize |> px)
            , displayFlex
            , alignItems center
            , property "justify-content" "center"
            , property "z-index" "1"
            ]
          , (.) ChampPortrait
            [ height (portraitHeight |> px)
            , width (portraitWidth |> px)
            , borderRadius (50 |> px)
            , backgroundColor Color.c_gold
            , property "z-index" "2"
            , marginLeft (-5 |> px)
            , marginRight (-7 |> px)
            ]
          , (.) ChampStats (
            [ displayFlex
            , width (champStatsWidth |> px)
            , height (champStatsHeight |> px)
            , property "justify-content" "center"
            , property "z-index" "0"
            ] ++ StyleUtils.flexDirection "column" ++
            [ children
              [ (.) ChampStat
                [ height (champStatHeight |> px)
                , width (100 |> pct)
                , backgroundColor Color.c_offWhite
                , margin (3 |> px)
                , children
                  [ (.) CurrentHp
                    [ backgroundColor Color.c_hp
                    ]
                  , (.) CurrentPower
                    [ backgroundColor Color.c_mp
                    ]
                  , (.) CurrentXp
                    [ backgroundColor Color.c_exp
                    ]
                  ]
                ]
              ]
            ])
          ]
        ]
        )
      , (.) PlayerStats (
        [ color Color.c_offWhite
        , displayFlex
        , alignItems flexEnd
        ] ++ StyleUtils.flexDirection "column" ++
        [ children
          [ p
            [ margin (5 |> px)
            ]
          , (.) PlayerIgn
            [ fontSize (playerIgnFontSize |> px)
            ]
          ]
        ])
      ]
    ])
  ]
