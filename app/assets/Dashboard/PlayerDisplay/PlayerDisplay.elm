module PlayerDisplay.PlayerDisplay exposing (..)

import Array
import Css exposing (height, pct, width, zero)
import GameModel exposing (..)
import Html exposing (..)
import Html.Attributes exposing (draggable, src)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (onClick, onMouseOut, onMouseOver)
import PlayerDisplay.Css exposing (CssClass(..), namespace)
import PlayerDisplay.Types exposing (Model, Msg(PlayerDisplayClicked, PlayerDisplayHovered, PlayerDisplayUnhovered))
import Set
import String
import StyleUtils exposing (styles)
import PlayerDisplay.Internal.Update as Update

{id, class, classList} = withNamespace namespace

init : Model
init =
  { selectedPlayers = Set.empty
  , hoveredPlayer = Nothing
  }

update : Msg -> Model -> (Model, Cmd Msg)
update = Update.update

view : Side -> Player -> Timestamp -> Model -> Html Msg
view side player timestamp model =
  let
    displayCss = case Set.member player.id model.selectedPlayers of
      True -> SelectedPlayer
      False -> PlayerDisplay
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
      [ class [displayCss, direction]
      , onClick (PlayerDisplayClicked player.id)
      , onMouseOver (PlayerDisplayHovered player.id)
      , onMouseOut (PlayerDisplayUnhovered)
      ]
      [ div
        [ class [ChampDisplay, direction]
        ]
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
