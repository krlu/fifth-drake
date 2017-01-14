module PlayerDisplay.PlayerDisplay exposing (..)

import Array
import Css exposing (height, pct, width, zero)
import GameModel exposing (..)
import Html exposing (..)
import Html.Attributes exposing (draggable, src)
import Html.CssHelpers exposing (withNamespace)
import PlayerDisplay.Css exposing (CssClass(..), namespace, Direction(..))
import PlayerDisplay.Internal.Plots exposing (plotData)
import PlayerDisplay.Types exposing (Msg(PlotInteraction))
import Plot
import StyleUtils exposing (styles)
import Svg
import Types exposing (TimeSelection(..))
import String

{id, class, classList} = withNamespace namespace

getDirection : Side -> Direction
getDirection side =
  case side of
    Blue -> Normal
    Red -> Reverse


view : TimeSelection -> Side -> Player -> Html Msg
view selection side player =
  let
    direction = getDirection side
  in
    div
      [ class [PlayerDisplay, Direction direction] ]
      ( case selection of
          Instant timestamp ->
            displayInstant timestamp direction player
          Range range ->
            displayRange range player
      )

displayRange : (Timestamp, Timestamp) -> Player -> List (Html Msg)
displayRange range player = [ Html.map PlotInteraction <| plotData range player ]


displayInstant : Timestamp -> Direction -> Player -> List (Html a)
displayInstant timestamp direction player =
  let
    dirClass = Direction direction
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
            [ class [ChampStat, dirClass] ]
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
      [ div
        [ class [ChampDisplay, dirClass] ]
        [ p
          [ class [PlayerLevel] ]
          [ text << toString <| level ]
        , div
          [ class [ChampPortrait, dirClass] ]
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
        [ class [PlayerStats, dirClass] ]
        [ p
          [ class [PlayerIgn] ]
          [ text player.ign ]
        , p
          [ class [Kda] ]
          [ text kda ]
        ]
      ]
