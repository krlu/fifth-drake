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
import Graph.Graph as Graph
import Html.Events exposing (onClick)

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
          model.timestamp
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
            [ PlayerDisplay.view side p model.timestamp
            ]
        )
      |> div [ class [PlayerDisplay] ]

    sideToDisplays side = (sideToTeamDisplay side, sideToPlayerDisplay side)

    controls =
      Controls.view
        model.timestamp
        model.game.metadata.gameLength
        model.controls
      |> Html.map ControlsMsg

    centerView = case model.viewType of
      Map -> Minimap.view model.minimap
      Stats -> Graph.view model.game

    bluePlayers = model.game.data.blueTeam.players
    redPlayers =  model.game.data.redTeam.players
    allPlayers = getPlayerIdsAndIgns bluePlayers redPlayers

    tagCarousel = TagCarousel.view model.tagCarousel allPlayers |> Html.map TagCarouselMsg
    ((blueTeamDisplay, bluePlayerDisplays), (redTeamDisplay, redPlayerDisplays))
      = (Blue, Red)
      |> mapBoth sideToDisplays
  in
    div
      [ class [Dashboard] ]
      [ button [onClick SwitchView] [text "switch view"],
        div
        [ class [TeamDisplays] ]
        [ blueTeamDisplay
        , redTeamDisplay
        ]
      , div
        [ id [MainContent] ]
        [ bluePlayerDisplays
        , div
          [ id [CenterContent] ]
          [ centerView
          , controls
          ]
        , redPlayerDisplays
        ]
      , tagCarousel
      ]

getPlayerIdsAndIgns: Array Player -> Array Player -> List (PlayerId, String, String, String)
getPlayerIdsAndIgns bluePlayers redPlayers =
  let
     blueData = bluePlayers |> Array.map (\player -> (player.id, player.ign, player.championName, player.championImage))
     redData = redPlayers |> Array.map (\player -> (player.id, player.ign, player.championName, player.championImage))
  in
      Array.append blueData redData |> Array.toList
