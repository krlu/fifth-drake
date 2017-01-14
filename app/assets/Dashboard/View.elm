module View exposing (..)

import Array exposing (Array)
import Controls.Controls as Controls
import DashboardCss exposing (CssClass(..), CssId(ControlsDivider, TeamDisplayDivider), namespace)
import GameModel exposing (GameLength, Side(..), Timestamp)
import Html exposing (..)
import Html.CssHelpers exposing (withNamespace)
import Minimap.Minimap as Minimap
import TagCarousel.TagCarousel as TagCarousel
import DashboardCss exposing (CssClass(..), CssId(..), namespace)
import GameModel exposing (..)
import PlayerDisplay.PlayerDisplay as PlayerDisplay
import TeamDisplay.TeamDisplay as TeamDisplay
import Types exposing (..)
import Tuple

{id, class, classList} = withNamespace namespace

mapBoth : (a -> b) -> (a, a) -> (b, b)
mapBoth f =
  Tuple.mapFirst f
  >> Tuple.mapSecond f

view : Model -> Html Msg
view model =
  let
    widget : Side -> List (Html a) -> Html a
    widget side html =
      div
        [ class [Widget, WidgetColor side] ]
        html

    sideToTeamDisplay side =
      widget side
        [ TeamDisplay.view
          (getTeamName side model.game.metadata)
          (getTeam side model.game.data)
          model.selection
        ]

    sideToPlayerDisplay side =
      getTeam side model.game.data
      |> .players
      |> Array.toList
      |> List.sortBy
        ( \p ->
          case p.role of
            Top -> 0
            Jungle -> 1
            Mid -> 2
            Bot -> 3
            Support -> 4
        )
      |> List.map
        (\p ->
          widget side
            [ PlayerDisplay.view model.selection side p
            ]
        )
      |> div [ class [PlayerDisplay] ] |> Html.map PlayerDisplayMsg

    controls =
      Controls.view
        model.selection
        model.game.metadata.gameLength
        model.controls
      |> Html.map ControlsMsg

    minimap = Minimap.view model.minimap model.game.data model.selection


    bluePlayers = model.game.data.blueTeam.players |> Array.toList
    redPlayers =  model.game.data.redTeam.players  |> Array.toList
    allPlayers =  bluePlayers ++ redPlayers

    tagCarousel = allPlayers
      |> List.map (\player -> (player.id, player.ign))
      |> TagCarousel.view model.tagCarousel
      |> Html.map TagCarouselMsg

    (blueTeamDisplay, redTeamDisplay)
      = (Blue, Red)
      |> mapBoth sideToTeamDisplay

    (bluePlayerDisplays, redPlayerDisplays)
      = (Blue, Red)
      |> mapBoth sideToPlayerDisplay

  in
    div
      [ class [Dashboard] ]
      [ div
        [ class [TeamDisplays] ]
        [ blueTeamDisplay
        , redTeamDisplay
        ]
      , div
        [ id [MainContent] ]
        [ bluePlayerDisplays
        , div
          [ id [CenterContent] ]
          [ minimap
          , controls
          ]
        , redPlayerDisplays
        ]
      , tagCarousel
      ]
