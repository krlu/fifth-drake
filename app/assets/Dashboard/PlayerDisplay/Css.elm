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
  [ class PlayerDisplay (
    [ displayFlex
    , width (playerDisplayWidth |> px)
    , height (playerDisplayHeight |> px)
    , padding (10 |> px)
    , justifyContent spaceBetween
    , alignItems flexStart
    , withClass DirNormal
      (StyleUtils.flexDirection "row")
    , withClass DirReverse
      (StyleUtils.flexDirection "row-reverse")
    , hover
      [ backgroundColor Color.c_hovering
      , cursor pointer
      ]
    , children
      [ class ChampDisplay (
        [ displayFlex
        , withClass DirNormal
          (StyleUtils.flexDirection "row")
        , withClass DirReverse
          (StyleUtils.flexDirection "row-reverse")
        , justifyContent flexStart
        , alignItems center
        , children
          [ class PlayerLevel
            [ backgroundColor Color.c_darkerGray
            , color Color.c_offWhite
            , height (levelHeight |> px)
            , width (levelWidth |> px)
            , borderRadius (50 |> pct)
            , margin (levelMargin |> px)
            , fontSize (levelFontSize |> px)
            , displayFlex
            , alignItems center
            , justifyContent center
            , zIndex (1 |> int)
            ]
          , class ChampPortrait
            [ height (portraitHeight |> px)
            , width (portraitWidth |> px)
            , backgroundColor Color.c_gold
            , zIndex (2 |> int)
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
          , class ChampStats (
            [ displayFlex
            , width (champStatsWidth |> px)
            , height (champStatsHeight |> px)
            , justifyContent center
            , zIndex (0 |> int)
            ] ++ StyleUtils.flexDirection "column" ++
            [ children
              [ class ChampStat
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
                  , class CurrentHp
                    [ backgroundColor Color.c_hp
                    ]
                  , class CurrentPower
                    [ backgroundColor Color.c_mp
                    ]
                  , class CurrentXp
                    [ backgroundColor Color.c_exp
                    ]
                  ]
                ]
              ]
            ])
          ]
        ]
        )
      , class PlayerStats (
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
          , class PlayerIgn
            [ fontSize (playerIgnFontSize |> px)
            ]
          ]
        ])
      ]
    ])
  , class SelectedPlayer
    [ backgroundColor Color.c_selected
    , hover [ cursor pointer ]
    , displayFlex
    , width (playerDisplayWidth |> px)
    , height (playerDisplayHeight |> px)
    , padding (10 |> px)
    , justifyContent spaceBetween
    , alignItems flexStart
    , withClass DirNormal
      (StyleUtils.flexDirection "row")
    , withClass DirReverse
      (StyleUtils.flexDirection "row-reverse")
    , children
      [ class ChampDisplay (
        [ displayFlex
        , withClass DirNormal
          (StyleUtils.flexDirection "row")
        , withClass DirReverse
          (StyleUtils.flexDirection "row-reverse")
        , justifyContent flexStart
        , alignItems center
        , children
          [ class PlayerLevel
            [ backgroundColor Color.c_darkerGray
            , color Color.c_offWhite
            , height (levelHeight |> px)
            , width (levelWidth |> px)
            , borderRadius (50 |> pct)
            , margin (levelMargin |> px)
            , fontSize (levelFontSize |> px)
            , displayFlex
            , alignItems center
            , justifyContent center
            , zIndex (1 |> int)
            ]
          , class ChampPortrait
            [ height (portraitHeight |> px)
            , width (portraitWidth |> px)
            , backgroundColor Color.c_gold
            , zIndex (2 |> int)
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
          , class ChampStats (
            [ displayFlex
            , width (champStatsWidth |> px)
            , height (champStatsHeight |> px)
            , justifyContent center
            , zIndex (0 |> int)
            ] ++ StyleUtils.flexDirection "column" ++
            [ children
              [ class ChampStat
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
                  , class CurrentHp
                    [ backgroundColor Color.c_hp
                    ]
                  , class CurrentPower
                    [ backgroundColor Color.c_mp
                    ]
                  , class CurrentXp
                    [ backgroundColor Color.c_exp
                    ]
                  ]
                ]
              ]
            ])
          ]
        ]
        )
      , class PlayerStats (
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
          , class PlayerIgn
            [ fontSize (playerIgnFontSize |> px)
            ]
          ]
        ])
      ]
    ]
  ]
