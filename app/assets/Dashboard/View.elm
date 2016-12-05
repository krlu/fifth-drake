module View exposing (..)

import Controls.Controls as Controls
import DashboardCss exposing (CssClass(..), CssId(ControlsDivider, TeamDisplayDivider), namespace)
import GameModel exposing (GameLength, Side(..), Timestamp, getTeam, getTeamName)
import Html exposing (..)
import Html.CssHelpers exposing (withNamespace)
import Minimap.Minimap as Minimap
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
    sideToTeamDisplay side =
      TeamDisplay.view
        side
        (getTeamName side model.game.metadata)
        (getTeam side model.game.data)
        model.timestamp

    controls =
      Controls.view
        model.timestamp
        model.game.metadata.gameLength
        model.controls
      |> Html.map ControlsMsg

    minimap = Minimap.view model.minimap model.game.data model.timestamp

    (blueTeamDisplay, redTeamDisplay) =
      (Blue, Red)
      |> mapBoth sideToTeamDisplay

  in
    div
      [ class [Dashboard] ]
      [ div
        [ class [TeamDisplays] ]
        [ blueTeamDisplay
        , redTeamDisplay
        ]
      , div [ id [TeamDisplayDivider] ] []
      , minimap
      , div [ id [ControlsDivider] ] []
      , controls
      ]

