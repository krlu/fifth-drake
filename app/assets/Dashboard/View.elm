module View exposing (..)

import Controls.Controls as Controls
import DashboardCss exposing (CssClass(..), namespace)
import Divider
import GameModel exposing (GameLength, Timestamp)
import Html exposing (..)
import Html.App
import Html.CssHelpers exposing (withNamespace)
import Minimap.Minimap as Minimap
import TagScroller.TagScroller as TagScroller
import Types exposing (..)

{id, class, classList} = withNamespace namespace

view : Model -> Html Msg
view model =
  let
      controls =
        Controls.view model.timestamp model.game.metadata.gameLength model.controls
        |> Html.App.map ControlsMsg
      minimap = Minimap.view model.minimap model.game.data model.timestamp
  in
    div
      [ class [Dashboard] ]
      [ minimap
      , Divider.horizontal
      , controls
      ]

