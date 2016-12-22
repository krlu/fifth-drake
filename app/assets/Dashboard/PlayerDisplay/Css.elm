module PlayerDisplay.Css exposing (..)

import Css exposing (..)
import Css.Elements exposing (img, p)
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

type Direction
  = Normal
  | Reverse

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
  | Direction Direction

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
    , withClass (Direction Normal)
      (StyleUtils.flexDirection "row")
    , withClass (Direction Reverse)
      (StyleUtils.flexDirection "row-reverse")
    , children
      [ (.) ChampDisplay (
        [ displayFlex
        , withClass (Direction Normal)
          (StyleUtils.flexDirection "row")
        , withClass (Direction Reverse)
          (StyleUtils.flexDirection "row-reverse")
        , property "justify-content" "flex-start"
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
            , backgroundColor Color.c_gold
            , property "z-index" "2"
            , withClass (Direction Normal)
              [ marginLeft (-5 |> px)
              ]
            , withClass (Direction Reverse)
              [ marginRight (-5 |> px)
              ]
            , children
              [ img
                [ width (100 |> pct)
                , height (100 |> pct)
                ]
              ]
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
                [ displayFlex
                , height (champStatHeight |> px)
                , width (100 |> pct)
                , backgroundColor Color.c_offWhite
                , margin (3 |> px)
                , withClass (Direction Normal)
                  (StyleUtils.flexDirection "row")
                , withClass (Direction Reverse)
                  (StyleUtils.flexDirection "row-reverse")
                , children
                  [ everything
                    [ height (100 |> pct)
                    ]
                  , (.) CurrentHp
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
        , withClass (Direction Normal)
          [ alignItems flexEnd
          ]
        , withClass (Direction Reverse)
          [ alignItems flexStart
          ]
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
