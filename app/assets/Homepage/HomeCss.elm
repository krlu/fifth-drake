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
  [(.) Home(
    [ width (100 |> pct)
    , overflowY scroll
    ])
  ,(.) Searchbar(
    [ fontSize (25 |> px)
    ])
  ,(.) RowItem(
    [ hover [backgroundColor Color.c_hovering]
    , backgroundColor Color.c_games_table_header
    , backgroundColor Color.c_games_table
    ])
  , table(
    [ width (100 |> pct)
    , fontSize (tableFontSize |> px)
    ])
  ,(.) TableHeader(
    [ backgroundColor Color.c_games_table_header
    , children
      [ (.) DateHeader(
        [ hover [backgroundColor Color.c_hovering, cursor pointer]
--        , width (250 |> px)
        ])
      ]
    ])
  ]
