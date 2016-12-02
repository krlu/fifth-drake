module View exposing (..)

import Controls.Controls as Controls
import DashboardCss exposing (CssClass(..), namespace)
import Divider
import GameModel exposing (GameLength, Side(..), Timestamp)
import Html exposing (..)
import Html.App
import Html.CssHelpers exposing (withNamespace)
import Minimap.Minimap as Minimap
import TagScroller.TagScroller as TagScroller
import TeamDisplay.TeamDisplay as TeamDisplay
import Types exposing (..)

{id, class, classList} = withNamespace namespace

view : Model -> Html Msg
view model =
  let
    controls =
      Controls.view
        model.timestamp
        model.game.metadata.gameLength
        model.controls
      |> Html.App.map ControlsMsg
    minimap = Minimap.view model.minimap model.game.data model.timestamp
    blueTeamDisplay =
      TeamDisplay.view
        Blue
        model.game.metadata.blueTeamName
        model.game.data.blueTeam
        model.timestamp
    redTeamDisplay =
      TeamDisplay.view
        Red
        model.game.metadata.redTeamName
        model.game.data.redTeam
        model.timestamp

  in
    div
      [ class [Dashboard] ]
      [ div
        [ class [TeamDisplays] ]
        [ blueTeamDisplay
        , redTeamDisplay
        ]
      , Divider.horizontal
      , minimap
      , Divider.horizontal
      , controls
      ]

