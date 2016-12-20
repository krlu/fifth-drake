module TeamDisplay.TeamDisplay exposing (..)

import Array
import GameModel exposing (..)
import Html exposing (..)
import Html.CssHelpers exposing (withNamespace)
import TeamDisplay.Css exposing (CssClass(..), namespace)

{id, class, classList} = withNamespace namespace

view : String -> Team -> Timestamp -> Html a
view name team timestamp =
  let
    teamState =
      Array.get timestamp team.teamStates
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
