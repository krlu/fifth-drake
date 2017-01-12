module Minimap.Internal.Update exposing (update)

import Animation exposing (Property, px)
import Array
import Dict exposing (Dict)
import GameModel exposing (..)
import Minimap.Css exposing (CssClass(..), minimapHeight, minimapWidth)
import Minimap.Types exposing (Action(..), Model, Msg(..), State)
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
    MoveIconStates action ->
      let
        newIconStates : Dict PlayerId State
        newIconStates =
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
                            let
                              newCoordinates : List Property
                              newCoordinates =
                                [ Animation.left (minimapWidth * (state.position.x / model.mapWidth)|> px)
                                , Animation.bottom (minimapHeight * (state.position.y / model.mapHeight)|> px)
                                ]
                              snap : Animation.State
                              snap =
                                ( Animation.interrupt
                                  [ Animation.set
                                    newCoordinates
                                  ]
                                  iconState.style
                                )
                              increment : Animation.State
                              increment =
                                ( Animation.queue
                                  [ Animation.toWith
                                    ( Animation.easing
                                      { duration = 1*second
                                      , ease = (\x -> x)
                                      }
                                    )
                                    newCoordinates
                                  ]
                                  iconState.style
                                )
                            in
                              case action of
                                Snap ->
                                  ( player.id
                                  , { iconState
                                    | style = snap
                                    }
                                  )
                                Increment ->
                                  ( player.id
                                  , { iconState
                                    | style = increment
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
        { model | iconStates = newIconStates }
