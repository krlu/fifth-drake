module Graph.Internal.PlotView exposing (..)

import Array
import Css exposing (height, pct, property, width, zero)
import GameModel exposing (..)
import Graph.Types exposing (Model, Msg(ChangeStat), Stat(Gold, HP, XP))
import Html exposing (..)
import Html.Attributes exposing (defaultValue, draggable, placeholder, placeholder, selected, src)
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

customHint : List (Plot.Hint.Attribute msg) -> Maybe Point -> Element msg
customHint attrs position = hint [viewCustom customView] position

customView : HintInfo -> Bool -> Html.Html msg
customView { xValue, yValues } isLeftSide =
    let
        classes =
            [ ( "elm-plot__hint__default-view", True )
            , ( "elm-plot__hint__default-view--left", isLeftSide )
            , ( "elm-plot__hint__default-view--right", not isLeftSide )
            ]
    in
        Html.div
            [ Html.Attributes.classList classes, class [HintCss] ]
            [ Html.div [] (List.indexedMap viewYValue yValues)
            ]


viewYValue : Int -> Maybe (List Float) -> Html.Html msg
viewYValue index hintValue =
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
        Html.div [class [HintCss]]
            [ Html.span [] [ Html.text ("Bjergsen") ]
            ]

