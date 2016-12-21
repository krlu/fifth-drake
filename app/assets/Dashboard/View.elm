module View exposing (..)

import Array
import Controls.Controls as Controls
import DashboardCss exposing (CssClass(..), CssId(ControlsDivider, TeamDisplayDivider, TagDisplay), namespace)
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
      |> List.intersperse (div [class [PlayerDisplayDivider]] [])
      |> div [ class [PlayerDisplay] ]

    sideToDisplays side = (sideToTeamDisplay side, sideToPlayerDisplay side)

    controls =
      Controls.view
        model.timestamp
        model.game.metadata.gameLength
        model.controls
      |> Html.map ControlsMsg

    minimap = Minimap.view model.minimap model.game.data model.timestamp
--    bluePlayers = model.game.data.blueTeam.players
--    redPlayers = model.game.data.redTeam.players
--    allPlayers = Array.append bluePlayers redPlayers |> Array.toList
--    tagCarousel = TagCarousel.view model.tagCarousel allPlayers |> Html.map TagCarouselMsg
    ((blueTeamDisplay, bluePlayerDisplays), (redTeamDisplay, redPlayerDisplays))
      = (Blue, Red)
      |> mapBoth sideToDisplays
  in
    div
      [ class [Dashboard] ]
      [ div
        [ class [TeamDisplays] ]
        [ blueTeamDisplay
        , redTeamDisplay
        ]
      , div [ id [TeamDisplayDivider] ] []
      , div
        [ id [MainContent] ]
        [ bluePlayerDisplays
        , div [ class [ContentDivider] ] []
        , div
          [ id [CenterContent] ]
          [ minimap
          , div [ id [ControlsDivider] ] []
          , controls
          ]
        , div [ class [ContentDivider] ] []
        , redPlayerDisplays
--      , div [id [TagDisplay]]
--        [ tagCarousel ]
        ]
      ]

