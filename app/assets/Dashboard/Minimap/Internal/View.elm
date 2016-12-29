module Minimap.Internal.View exposing (..)

import Animation
import Dict
import Html exposing (..)
import Html.Attributes exposing (src, draggable)
import Html.CssHelpers exposing (withNamespace)
import Minimap.Css exposing (CssClass(..), namespace)
import Minimap.Types exposing (Model)
import GameModel exposing (..)

{id, class, classList} = withNamespace namespace

view : Model -> Html a
view model =
  let
    playerIcons : List (Html a)
    playerIcons =
      Dict.values model.iconStates
      |> List.map (\iconState ->
          div
            ([ class
              [ PlayerIcon
              , IconColor iconState.side
              ]
            ]
            ++ (Animation.render iconState.style))
            []
        )
  in
    div [ class [Minimap]
        ]
      (
        [ img [ class [Background]
              , src model.background
              , draggable "false"
              ]
            []
        ]
        ++ playerIcons
      )
