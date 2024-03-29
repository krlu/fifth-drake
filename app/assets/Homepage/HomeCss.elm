module HomeCss exposing (..)

import Css exposing (..)
import Css.Elements exposing (table, td, tr)
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
  | DateHeader

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [class Home(
    [ width (100 |> pct)
    , overflowY scroll
    ])
  ,class Searchbar(
    [ fontSize (25 |> px)
    ])
  ,class RowItem(
    [ hover [backgroundColor Color.c_hovering]
    , backgroundColor Color.c_games_table
    ])
  ,Css.Elements.table(
    [ width (90 |> pct)
    , fontSize (tableFontSize |> px)
    ])
  ,class TableHeader(
    [ backgroundColor Color.c_table_header
    , children
      [ class DateHeader(
        [ hover [backgroundColor Color.c_hovering, cursor pointer]
        ])
      ]
    ])
  ]
