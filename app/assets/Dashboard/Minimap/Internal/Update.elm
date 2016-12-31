module Minimap.Internal.Update exposing (update)

import Animation exposing (px)
import Array
import Dict exposing (Dict)
import GameModel exposing (..)
import Minimap.Css exposing (CssClass(..), minimapHeight, minimapWidth)
import Minimap.Types exposing (Model, Msg(..), State)
import Time exposing (second)

onStyle : (Animation.State -> Animation.State) -> State -> State
onStyle styleFn state =
    { state | style = styleFn state.style }


update : Model -> Data -> Timestamp -> Msg -> Model
update model data timestamp msg =
  case msg of
    GenerateIconStates ->
      let
        newIconState : Dict PlayerId State
        newIconState =
          data
            |> (\{blueTeam, redTeam} ->
                let
                  teamToIconState : Team -> Side -> List ( PlayerId, State )
                  teamToIconState team side =
                    team.players
                    |> Array.toList
                    |> List.filterMap (\player ->
                      player.state
                      |> Array.get timestamp
                      |> Maybe.map (\state ->
                        ( player.id
                        , { style =
                            Animation.style
                              [ Animation.left (minimapWidth * (state.position.x / model.mapWidth)|> px)
                              , Animation.bottom (minimapHeight * (state.position.y / model.mapHeight)|> px)
                              ]
                          , side = side
                          , img = player.championImage
                          }
                        )
                      )
                    )
                in
                  Dict.fromList <|
                    (teamToIconState blueTeam Blue) ++
                    (teamToIconState redTeam Red)
                )
      in
        { model | iconStates = newIconState }
    AnimatePlayerIcons animationMsg ->
      { model
      | iconStates =
        Dict.map (\_ iconState ->
          { iconState
          | style = Animation.update animationMsg iconState.style
          }
        )
        model.iconStates
      }
    IncrementIconStates ->
      let
        newIconState : Dict PlayerId State
        newIconState =
          data
            |> (\{blueTeam, redTeam} ->
                let
                  teamToIconState : Team -> Side -> List ( PlayerId, State )
                  teamToIconState team side =
                    team.players
                    |> Array.toList
                    |> List.filterMap (\player ->
                      player.state
                      |> Array.get timestamp
                      |> Maybe.andThen (\state ->
                        (Dict.get player.id model.iconStates)
                        |> Maybe.map (\iconState ->
                          ( player.id
                          , { iconState
                            | style =
                              ( Animation.queue
                                [ Animation.toWith
                                  ( Animation.easing
                                    { duration = 1*second
                                    , ease = (\x -> x)
                                    }
                                  )
                                  [ Animation.left (minimapWidth * (state.position.x / model.mapWidth)|> px)
                                  , Animation.bottom (minimapHeight * (state.position.y / model.mapHeight)|> px)
                                  ]
                                ]
                                iconState.style
                              )
                            }
                          )
                        )
                      )
                    )
                in
                  Dict.fromList <|
                    (teamToIconState blueTeam Blue) ++
                    (teamToIconState redTeam Red)
                )
      in
        { model | iconStates = newIconState }
    SnapIconStates ->
      let
        newIconState : Dict PlayerId State
        newIconState =
          data
            |> (\{blueTeam, redTeam} ->
                let
                  teamToIconState : Team -> Side -> List ( PlayerId, State )
                  teamToIconState team side =
                    team.players
                    |> Array.toList
                    |> List.filterMap (\player ->
                      player.state
                      |> Array.get timestamp
                      |> Maybe.andThen (\state ->
                        (Dict.get player.id model.iconStates)
                        |> Maybe.map (\iconState ->
                          ( player.id
                          , { iconState
                            | style =
                              ( Animation.interrupt
                                [ Animation.set
                                  [ Animation.left (minimapWidth * (state.position.x / model.mapWidth)|> px)
                                  , Animation.bottom (minimapHeight * (state.position.y / model.mapHeight)|> px)
                                  ]
                                ]
                                iconState.style
                              )
                            }
                          )
                        )
                      )
                    )
                in
                  Dict.fromList <|
                    (teamToIconState blueTeam Blue) ++
                    (teamToIconState redTeam Red)
                )
      in
        { model | iconStates = newIconState }