module Minimap.Internal.View exposing (..)

import Animation
import Css exposing (backgroundImage)
import Dict
import Html exposing (..)
import Html.Attributes exposing (src, draggable)
import Html.CssHelpers exposing (style, withNamespace)
import Minimap.Css exposing (CssClass(..), namespace)
import Minimap.Types exposing (Model)
import GameModel exposing (..)
import StyleUtils exposing (styles)

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
            [ img
              [ class [ChampionImage]
              , src iconState.img
              , draggable "false"
              ]
              []
            ]
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
