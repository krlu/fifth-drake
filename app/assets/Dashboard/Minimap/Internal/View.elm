module Minimap.Internal.View exposing (..)

import Array
import Css exposing (bottom, left, property, px)
import Html exposing (..)
import Html.Attributes exposing (src, draggable)
import Html.CssHelpers exposing (withNamespace)
import Maybe exposing (andThen)
import Minimap.Css exposing (CssClass(..), minimapHeight, minimapWidth, namespace)
import Minimap.Types exposing (Model)
import StyleUtils exposing (styles)
import GameModel exposing (Data, Team, Timestamp)


{ id, class, classList } =
    withNamespace namespace


view : Model -> Data -> Timestamp -> Html a
view model data timestamp =
    let
        playerIcons : List (Html a)
        playerIcons =
            data
                |> (\{ blueTeam, redTeam } ->
                        let
                            teamToPlayerIcons : Team -> List (Html a)
                            teamToPlayerIcons team =
                                team.players
                                    |> Array.toList
                                    |> List.filterMap
                                        (\player ->
                                            player.state
                                                |> Array.get timestamp
                                                |> Maybe.map
                                                    (\state ->
                                                        div
                                                            [ class [ PlayerIcon ]
                                                            , styles
                                                                [ left (minimapWidth.numericValue * (state.position.x / model.mapWidth) |> px)
                                                                , bottom (minimapHeight.numericValue * (state.position.y / model.mapHeight) |> px)
                                                                ]
                                                            ]
                                                            [ img
                                                                [ class [ ChampionImage ]
                                                                , src player.championImage
                                                                , draggable "false"
                                                                ]
                                                                []
                                                            ]
                                                    )
                                        )
                        in
                            (teamToPlayerIcons blueTeam)
                                ++ (teamToPlayerIcons redTeam)
                   )
    in
        div
            [ class [ Minimap ]
            ]
            ([ img
                [ class [ Background ]
                , src model.background
                , draggable "false"
                ]
                []
             ]
                ++ playerIcons
            )
