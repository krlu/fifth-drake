module HomeCss exposing (..)

import Css exposing (..)
import Css.Elements exposing (table, td)
import Css.Namespace
import CssColors as Color

namespace : String
namespace = "home"

tableFontSize : Float
tableFontSize = 25

type CssClass
  = Home
  | Searchbar
  | RowItem
  | TableHeader
  | TableBody

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [(.) Home(
    [ width (100 |> pct)
    , overflowY scroll
    ])
  ,(.) Searchbar(
    [ fontSize (25 |> px)
    ])
  , td(
    [ marginLeft (50 |> px)
    , borderStyle solid
    ])
  , table(
    [ width (100 |> pct)
    , fontSize (tableFontSize |> px)
    ])
  ,(.) TableHeader(
    [ backgroundColor Color.c_games_table_header
    ])
  ,(.) TableBody(
    [ backgroundColor Color.c_games_table_header
    , backgroundColor Color.c_games_table
    ])
  ]
