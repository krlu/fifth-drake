module PlayerDisplay.Css exposing (..)

import Css exposing (..)
import Css.Elements exposing (img, p)
import Css.Namespace
import CssColors as Color
import GameModel exposing (Side)
import StyleUtils

namespace : String
namespace = "playerDisplay"

playerDisplayWidth = 275
playerDisplayHeight = 60

playerIgnFontSize = 16

levelHeight = 30
levelWidth = levelHeight
levelMargin = 7
levelFontSize = 18

portraitHeight = 38
portraitWidth = portraitHeight

champStatsWidth = 100
champStatsHeight = portraitHeight
champStatsMargin = 3

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
  | DirNormal
  | DirReverse
  | SelectedPlayer

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
    , withClass DirNormal
      (StyleUtils.flexDirection "row")
    , withClass DirReverse
      (StyleUtils.flexDirection "row-reverse")
    , hover [backgroundColor Color.c_hovering]
    , children
      [ (.) ChampDisplay (
        [ displayFlex
        , withClass DirNormal
          (StyleUtils.flexDirection "row")
        , withClass DirReverse
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
            , margin (levelMargin |> px)
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
            , withClass DirNormal
              [ marginLeft (-5 |> px)
              ]
            , withClass DirReverse
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
                , margin (champStatsMargin |> px)
                , withClass DirNormal
                  (StyleUtils.flexDirection "row" ++
                  [ paddingLeft (0 |> px) ]
                  )
                , withClass DirReverse
                  (StyleUtils.flexDirection "row-reverse" ++
                  [ paddingRight (0 |> px) ]
                  )
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
        , withClass DirNormal
          [ alignItems flexEnd
          ]
        , withClass DirReverse
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
  , (.) SelectedPlayer
    [ backgroundColor Color.c_selected
    , hover
      [ backgroundColor Color.c_selected
      ]
    , displayFlex
    , width (playerDisplayWidth |> px)
    , height (playerDisplayHeight |> px)
    , padding (10 |> px)
    , property "justify-content" "space-between"
    , alignItems flexStart
    , withClass DirNormal
      (StyleUtils.flexDirection "row")
    , withClass DirReverse
      (StyleUtils.flexDirection "row-reverse")
    , children
      [ (.) ChampDisplay (
        [ displayFlex
        , withClass DirNormal
          (StyleUtils.flexDirection "row")
        , withClass DirReverse
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
            , margin (levelMargin |> px)
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
            , withClass DirNormal
              [ marginLeft (-5 |> px)
              ]
            , withClass DirReverse
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
                , margin (champStatsMargin |> px)
                , withClass DirNormal
                  (StyleUtils.flexDirection "row" ++
                  [ paddingLeft (0 |> px) ]
                  )
                , withClass DirReverse
                  (StyleUtils.flexDirection "row-reverse" ++
                  [ paddingRight (0 |> px) ]
                  )
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
        , withClass DirNormal
          [ alignItems flexEnd
          ]
        , withClass DirReverse
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
    ]
  ]
