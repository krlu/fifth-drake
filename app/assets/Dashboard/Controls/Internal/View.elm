module Controls.Internal.View exposing (view)

import Controls.Css exposing (CssClass(..), namespace, timelineWidth)
import Controls.Internal.ModelUtils exposing(..)
import Controls.Types exposing (..)
import Css exposing (left, px)
import DashboardCss
import GameModel exposing (GameLength, Timestamp)
import Html exposing (..)
import Html.Attributes exposing (checked, src, type_)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (on, onCheck, onClick)
import Json.Decode as Json exposing (Decoder, andThen, field, int, map2)
import Mouse
import StyleUtils exposing (..)
import Types exposing (TimeSelection(..))

{id, class, classList} = withNamespace namespace

join : Decoder a -> Decoder b -> Decoder (a,b)
join da db =
  da
  |> Json.andThen (\x -> Json.map (\y -> (x, y)) db)

{- This decoder will create both an absolute and relative position out of the
   provided mouse input.

   @return (absolute, relative)
-}
relativePosition : Decoder (Mouse.Position, Mouse.Position)
relativePosition =
  join
    Mouse.position <|
    map2 Mouse.Position
      (field "offsetX" int)
      (field "offsetY" int)

view : TimeSelection -> GameLength -> Model -> Html Msg
view selection gameLength model =
  let
    playImg =
      -- This needs to show the opposing state. If it's currently playing, then
      -- you want to show pause.
      case model.status of
        Play -> model.pauseButton
        Pause -> model.playButton
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
      , timeline selection gameLength model
      ]

timeline : TimeSelection -> GameLength -> Model -> Html Msg
timeline selection gameLength model =
  let
    timeDisplayText : String
    timeDisplayText =
      (case selection of
         Instant t ->
           toTimeString t
         Range (start, end) ->
           toTimeString start ++ " - " ++ toTimeString end
      )
      ++ "/" ++ toTimeString gameLength

    (firstKnobLocation, secondKnobLocation) =
      let
        timestamps =
          case selection of
            Instant t -> (t, Nothing)
            Range (start, end) -> (start, Just end)
        timestampToPixels = getPixelForTimestamp model gameLength
      in
        timestamps
        |> Tuple.mapFirst timestampToPixels
        |> Tuple.mapSecond (Maybe.map timestampToPixels)

  in
    div
      [ class [TimelineAndDisplay] ]
      [ label
        [ class [SecondKnobSelector] ]
        [ p [] [text "Select Range:"]
        , input
          [ type_ "checkbox"
          , checked
            ( case secondKnobLocation of
                Nothing -> False
                Just _ -> True
            )
          , onCheck UseSecondKnob
          ]
          []
        ]
      , div
        [ class [Timeline]
          , on "mousedown" (Json.map BarClick relativePosition)
        ]
        [ div
          [ class [BarSeen]
          , styles
            [ Css.width (firstKnobLocation |> px)
            ]
          ]
          []
        ]
      , p
        [ class [TimeDisplay] ]
        [ text timeDisplayText
        ]
      , div
        [ on "mousedown" (Json.map KnobGrab Mouse.position)
        , class [Knob]
        , styles
          [ left (firstKnobLocation |> px)
          ]
        ]
        []
      ]
