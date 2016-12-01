module Controls.Internal.View exposing (view)

import Controls.Css exposing (CssClass(..), namespace, timelineWidth)
import Controls.Internal.ModelUtils exposing(..)
import Controls.Types exposing (Msg(KnobGrab, BarClick, PlayPause), Model, Status(..))
import Css exposing (left, px)
import DashboardCss
import GameModel exposing (GameLength, Timestamp)
import Html exposing (..)
import Html.Attributes exposing (src)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (on, onClick)
import Json.Decode as Json exposing ((:=), Decoder, andThen, int, object2)
import Mouse
import StyleUtils exposing (..)

{id, class, classList} = withNamespace namespace

join : Decoder a -> Decoder b -> Decoder (a,b)
join da db =
  da
  |> flip Json.andThen (\x -> Json.map (\y -> (x, y)) db)

relativePosition : Decoder (Mouse.Position, Mouse.Position)
relativePosition =
  join
    Mouse.position <|
    object2 Mouse.Position
      ("offsetX" := int)
      ("offsetY" := int)

view : Timestamp -> GameLength -> Model -> Html Msg
view timestamp gameLength model =
  let
    playImg = -- Yes this is intentional
      case model.status of
        Play -> model.pauseButton
        Pause -> model.playButton
    pxs = getPixelForTimestamp model timestamp gameLength
  in
    div
      [ class [Controls] ]
      [ button
        [ class [PlayButton]
        , onClick PlayPause
        ]
        [ img
          [ class [PlayPauseImg]
          , src playImg
          ]
          []
        ]
      , div
        [ class [TimelineAndDisplay] ]
        [ p
          [ class [TimeDisplay, Hidden] ]
          [ text <| toTimeString timestamp ++ "/" ++ toTimeString gameLength
          ]
        , div
          [ class [Timeline]
            , on "mousedown" (Json.map BarClick relativePosition)
          ]
          [ div
            [ class [BarSeen]
            , styles
              [ Css.width (pxs |> px)
              ]
            ]
            []
          ]
        , p
          [ class [TimeDisplay] ]
          [ text <| toTimeString timestamp ++ "/" ++ toTimeString gameLength
          ]
        , div
          [ on "mousedown" (Json.map KnobGrab Mouse.position)
          , class [Knob]
          , styles
            [ left (pxs |> px)
            ]
          ]
          []
        ]
      ]
