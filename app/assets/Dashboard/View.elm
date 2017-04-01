module View exposing (..)

import Array exposing (Array)
import Controls.Controls as Controls
import DashboardCss exposing (CssClass(..), CssId(ControlsDivider, TeamDisplayDivider), namespace)
import GameModel exposing (GameLength, Side(..), Timestamp)
import Html exposing (..)
import Html.Attributes exposing (src)
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
import String

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
            [ PlayerDisplay.view side p model.timestamp model.playerDisplay |> Html.map PlayerDisplayMsg
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
      Map -> [Minimap.view model.minimap model.game.data, controls]
      Stats -> [Graph.view model.graphStat model.game model.playerDisplay.selectedPlayers |> Html.map GraphMsg]

    bluePlayers = model.game.data.blueTeam.players
    redPlayers =  model.game.data.redTeam.players
    allPlayers = getPlayerIdsAndIgns bluePlayers redPlayers

    tagCarousel =
      TagCarousel.view model.tagCarousel model.permissions model.currentUser.id allPlayers
      |> Html.map TagCarouselMsg
    ((blueTeamDisplay, bluePlayerDisplays), (redTeamDisplay, redPlayerDisplays))
      = (Blue, Red)
      |> mapBoth sideToDisplays
    switchLabel =
      case model.viewType of
        Map -> " View"
        Stats -> "Map View"
    loadedCenterView =
      case String.length model.currentUser.id of
       0 ->
        div [id [CenterContent], class [LoadingCenterContent]]
        [ img [ src model.loadingIcon, id [LoadingCss] ] []
        ]
       _ ->
        div [ id [CenterContent] ]
          centerView
  in
    div
      [ class [Dashboard] ]
      [ div [ class [SwitchCss], onClick SwitchView] [text switchLabel],
        div
        [ class [TeamDisplays] ]
        [ blueTeamDisplay
        , redTeamDisplay
        ]
      , div
        [ id [MainContent] ]
        [ bluePlayerDisplays
        , loadedCenterView
        , redPlayerDisplays
        ]
      , tagCarousel
      ]

getPlayerIdsAndIgns: Array Player -> Array Player -> List (PlayerId, Ign, Name, Image)
getPlayerIdsAndIgns bluePlayers redPlayers =
  let
     blueData = bluePlayers |> Array.map (\player -> (player.id, player.ign, player.championName, player.championImage))
     redData = redPlayers |> Array.map (\player -> (player.id, player.ign, player.championName, player.championImage))
  in
      Array.append blueData redData |> Array.toList
