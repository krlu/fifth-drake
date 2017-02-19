module Minimap.Internal.Update exposing (update)

import Animation exposing (Property, px)
import Array
import Dict exposing (Dict)
import GameModel exposing (..)
import Configuration exposing (animationTime)
import Minimap.Css exposing (CssClass(..), minimapHeight, minimapWidth)
import Minimap.Types exposing (Model, Msg(..), State)
import PlaybackTypes exposing (..)

epsilon : Float
epsilon = 0.00001

animationTimeScalar : Float
animationTimeScalar = 0.925

onStyle : (Animation.State -> Animation.State) -> State -> State
onStyle styleFn state =
    { state | style = styleFn state.style }

mapPlayerStates : Data -> Timestamp -> (Side -> Player -> PlayerState -> (Maybe (PlayerId, State))) -> Dict PlayerId State
mapPlayerStates data timestamp updateIconState =
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
              |> Maybe.andThen (updateIconState side player)
            )
        in
          Dict.fromList <|
            (teamToIconState blueTeam Blue) ++
            (teamToIconState redTeam Red)
        )

update : Model -> Data -> Timestamp -> Msg -> Model
update model data timestamp msg =
  case msg of
    GenerateIconStates ->
      let
        newIconStates : Dict PlayerId State
        newIconStates =
          mapPlayerStates data timestamp
            (\side player state ->
              Just <|
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
      in
        { model | iconStates = newIconStates }
    MoveIconStates action ->
      let
        newIconStates : Dict PlayerId State
        newIconStates =
          mapPlayerStates data timestamp
            (\side player state ->
              (Dict.get player.id model.iconStates)
              |> Maybe.map (\iconState ->
                  let
                    opacity : Float
                    opacity =
                      case state.championState.hp > epsilon of
                        True -> 1.0
                        False -> 0.0
                    newCoordinates : List Property
                    newCoordinates =
                      [ Animation.left (minimapWidth * (state.position.x / model.mapWidth)|> px)
                      , Animation.bottom (minimapHeight * (state.position.y / model.mapHeight)|> px)
                      , Animation.opacity (opacity)
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
                            { duration = animationTimeScalar * animationTime
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
                      NoAction ->
                        ( player.id
                        , { iconState
                          | style = iconState.style
                          }
                        )
              )
            )
      in
        { model | iconStates = newIconStates }
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
