module Graph.Internal.PlotView exposing (customHintCreator)

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
      Html.div
        [ class [HintCss] ]
        [ Html.div [] [ Html.text ("Timestamp: " ++ toString xValue) ]
        , Html.div [] (List.map viewYData
                       <| List.reverse
                       <| List.sortWith customComparison
                       <| List.map (\(player, value) -> (player, hintValueDisplayed value))
                       <| List.filter (\(player, value) -> hasSingleValue value)
                       <| zip playerHintDataList yValues)
        ]
  in
    customView

customComparison: ((Ign, Graph.Types.Color), Float) -> ((Ign, Graph.Types.Color), Float) -> Order
customComparison (player1, value1) (player2, value2) = compare value1 value2

-- The two methods below are explicitly for extracting the Value from yValue
-- Which is a Maybe (List Float). I want all cases where the yValue is a singleton.
-- The Reason for going through this trouble right now is because elm.plot doesn't
-- enable customizable hintInfo data structure, so I cannot make the yValues a list of singletons
-- @krlu 3-1-2017

hasSingleValue : Maybe (List Float) -> Bool
hasSingleValue hintValue =
        case hintValue of
          Just value ->
            case value of
              [ singleY ] -> True
              _ -> False
          Nothing -> False

hintValueDisplayed: Maybe (List Float) -> Float
hintValueDisplayed hintValue =
  case hintValue of
    Just value ->
      case value of
        [ singleY ] -> singleY
        _ -> 0
    Nothing -> 0

---------------------------------------------------------------------------------------------------

viewYData : ((Ign, Graph.Types.Color), Float) -> Html.Html msg
viewYData ((ign, color), hintValue) =
  Html.div
    [ Html.Attributes.style
      [ ("color", color)
      ]
    ]
    [ Html.span [] [ Html.text (ign ++ " : ")]
    , Html.span [] [ Html.text (toString hintValue)]
    ]

zip : List a -> List b -> List (a,b)
zip xs ys =
  case (xs, ys) of
    ( x :: xBack, y :: yBack ) ->
        (x,y) :: zip xBack yBack

    (_, _) ->
        []
