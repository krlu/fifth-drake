module Graph.Internal.PlotView exposing (..)

import Array
import Css exposing (height, pct, property, width, zero)
import GameModel exposing (..)
import Graph.Types exposing (Model, Msg(ChangeStat), Stat(Gold, HP, XP))
import Html exposing (..)
import Html.Attributes exposing (defaultValue, draggable, placeholder, placeholder, selected, src, style)
import Html.CssHelpers exposing (withNamespace)
import Graph.Css exposing (CssClass(..), namespace)
import Html.Events exposing (onInput)
import Plot exposing (..)
import Plot.Line exposing (stroke, strokeWidth)
import Plot.Label as Label
import Plot.Axis as Axis
import Set exposing (Set)
import String
import Tuple
import Plot.Hint exposing (HintInfo, viewCustom, Attribute)

{id, class, classList} = withNamespace namespace

customHintCreator : List(Ign, Graph.Types.Color) -> (List (Plot.Hint.Attribute msg) -> Maybe Point -> Element msg)
customHintCreator playerHintDataList =
  let
    customHint : List (Plot.Hint.Attribute msg) -> Maybe Point -> Element msg
    customHint attrs position =   hint [viewCustom (customViewGenerator playerHintDataList)] position
  in
    customHint

customViewGenerator : List(Ign, Graph.Types.Color) -> (HintInfo -> Bool -> Html.Html msg)
customViewGenerator playerHintDataList  =
  let
    customView : HintInfo -> Bool -> Html.Html msg
    customView { xValue, yValues } isLeftSide  =
      let
        classes =
          [ ( "elm-plot__hint__default-view", True )
          , ( "elm-plot__hint__default-view--left", isLeftSide )
          , ( "elm-plot__hint__default-view--right", not isLeftSide )
          ]
      in
        Html.div
          [ Html.Attributes.classList classes, class [HintCss] ]
          [ Html.div [] (List.map viewYValues <| zip playerHintDataList yValues)
          ]
  in
    customView


viewYValues : ((Ign, Graph.Types.Color), Maybe (List Float)) -> Html.Html msg
viewYValues ((ign, color), hintValue) =
  let
    hintValueDisplayed =
      case hintValue of
        Just value ->
          case value of
            [ singleY ] ->
              toString singleY
            _ ->
              toString value
        Nothing ->
            "~"
  in
    Html.div
      [ Html.Attributes.style
        [ ("color", color)
        ]
      ]
      [ Html.span [] [ Html.text (ign ++ " : ")]
      , Html.span [] [ Html.text hintValueDisplayed ]
      ]

zip : List a -> List b -> List (a,b)
zip xs ys =
  case (xs, ys) of
    ( x :: xBack, y :: yBack ) ->
        (x,y) :: zip xBack yBack

    (_, _) ->
        []
