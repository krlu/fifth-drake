module Graph.Graph exposing (..)

import Array
import Css exposing (height, pct, width, zero)
import GameModel exposing (..)
import Html exposing (..)
import Html.Attributes exposing (draggable, src)
import Html.CssHelpers exposing (withNamespace)
import Graph.Css exposing (CssClass(..), namespace)
import String
import StyleUtils exposing (styles)

{id, class, classList} = withNamespace namespace

view : Game -> Html a
view game = div[class [Graph]][]
