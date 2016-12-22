module TeamDisplay.TeamDisplay exposing (..)

import Array
import GameModel exposing (..)
import Html exposing (..)
import Html.CssHelpers exposing (withNamespace)
import Maybe exposing (andThen)
import TeamDisplay.Css exposing (CssClass(..), namespace)
import Types exposing (TimeSelection(..))

{id, class, classList} = withNamespace namespace

view : String -> Team -> TimeSelection -> Html a
view name team selection =
  let
    teamState =
      (case selection of
        Instant timestamp ->
          Array.get timestamp team.teamStates
        Range (start, end) ->
          -- Sometimes you really wish you had `do` notation.
          Array.get start team.teamStates
          |> andThen (\startState ->
            Array.get end team.teamStates
            |> Maybe.map (\endState ->
              { dragons = endState.dragons - startState.dragons
              , barons = endState.barons - startState.barons
              , turrets = endState.turrets - startState.turrets
              }
            )
          )
      )
      |> Maybe.map (\{turrets, dragons, barons} ->
        { dragons = toString dragons
        , barons = toString barons
        , turrets = toString turrets
        })
      |> Maybe.withDefault
        { dragons = "N/A"
        , barons = "N/A"
        , turrets = "N/A"
        }
    stats : String -> String -> Html a
    stats value label =
      p
        []
        [ text <| value ++ " "
        , span
          [class [Label] ]
          [text label]
        ]
  in
    div
      [ class [ TeamDisplay] ]
      [ h1
        []
        [ text name ]
      , div
        [ class [TeamStats] ]
        [ stats teamState.dragons "dragons"
        , stats teamState.barons "barons"
        , stats teamState.turrets "turrets"
        ]
      ]
