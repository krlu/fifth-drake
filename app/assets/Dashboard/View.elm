module View exposing (..)

import Array
import Controls.Controls as Controls
import DashboardCss exposing (CssClass(..), CssId(..), namespace)
import GameModel exposing (..)
import Html exposing (..)
import Html.CssHelpers exposing (withNamespace)
import Minimap.Minimap as Minimap
import PlayerDisplay.PlayerDisplay as PlayerDisplay
import TagScroller.TagScroller as TagScroller
import TeamDisplay.TeamDisplay as TeamDisplay
import Types exposing (..)

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
      |> Array.map
        (\p ->
          widget side
            [ PlayerDisplay.view p model.timestamp
            ]
        )
      |> Array.toList
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
        ]
      ]

