module View exposing (..)

import Controls.Controls as Controls
import DashboardCss exposing (CssClass(..), CssId(ControlsDivider, TeamDisplayDivider, TagDisplay), namespace)
import GameModel exposing (GameLength, Side(..), Timestamp)
import Html exposing (..)
import Html.CssHelpers exposing (withNamespace)
import Minimap.Minimap as Minimap
import TagCarousel.TagCarousel as TagCarousel
import TagForm.TagForm as TagForm
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
      |> Html.map ControlsMsg
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
    tagCarousel = TagCarousel.view model.tagCarousel |> Html.map TagCarouselMsg
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
      , div [id [TagDisplay]]
        [ tagCarousel ]
      ]

