module PlayerDisplay.PlayerDisplay exposing (..)

import Array
import Css exposing (height, pct, width, zero)
import GameModel exposing (..)
import Html exposing (..)
import Html.Attributes exposing (draggable, src)
import Html.CssHelpers exposing (withNamespace)
import PlayerDisplay.Css exposing (CssClass(..), namespace)
import StyleUtils exposing (styles)
import Types exposing (TimeSelection(..))

{id, class, classList} = withNamespace namespace

view : TimeSelection -> Side -> Player -> Html a
view selection =
  case selection of
    Instant timestamp ->
      displayInstant timestamp
    Range range ->
      displayRange range

displayRange : (Timestamp, Timestamp) -> Side -> Player -> Html a
displayRange range side player = div [] []

displayInstant : Timestamp -> Side -> Player -> Html a
displayInstant timestamp side player =
  let
    direction =
      case side of
        Blue -> DirNormal
        Red -> DirReverse

    kda =
      Array.get timestamp player.state
      |> Maybe.map (\state ->
          [ state.kills
          , state.deaths
          , state.assists
          ]
          |> List.map toString
          |> String.join " / "
        )
      |> Maybe.withDefault "Parse failed"

    level : Level
    level =
      Array.get timestamp player.state
      |> Maybe.map (getCurrentLevel << .xp << .championState)
      |> Maybe.withDefault 0

    champStats : List (Html a)
    champStats =
      [ (CurrentHp, .hp, .hpMax)
      , (CurrentPower, .power, .powerMax)
      , ( CurrentXp
        , \x -> x.xp - getXpRequiredForLevel level
        , always <| getXpRequiredForLevel (level + 1) - getXpRequiredForLevel level
        )
      ]
      |> List.map (\(cssClass, current, max) ->
          div
            [ class [ChampStat, direction] ]
            [ div
              [ class [cssClass]
              , styles
                [ width
                  ( Array.get timestamp player.state
                    |> Maybe.map
                      (\state ->
                        current state.championState / max state.championState
                        |> (*) 100
                        |> pct
                      )
                    |> Maybe.withDefault (0 |> pct) -- can't use `zero`
                  )
                ]
              ]
              []
            ]
          )
  in
    div
      [ class [PlayerDisplay, direction] ]
      [ div
        [ class [ChampDisplay, direction] ]
        [ p
          [ class [PlayerLevel] ]
          [ text << toString <| level ]
        , div
          [ class [ChampPortrait, direction] ]
          [ img
              [ src player.championImage
              , draggable "false"
              ]
              []
          ]
        , div
          [ class [ChampStats] ]
          champStats
        ]
      , div
        [ class [PlayerStats, direction] ]
        [ p
          [ class [PlayerIgn] ]
          [ text player.ign ]
        , p
          [ class [Kda] ]
          [ text kda ]
        ]
      ]
