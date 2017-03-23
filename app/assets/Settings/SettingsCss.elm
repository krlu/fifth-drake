module SettingsCss exposing (..)

import Css exposing (..)
import Css.Elements exposing (table, td, tr)
import Css.Namespace
import CssColors as Color

namespace : String
namespace = "settings"

tableFontSize : Float
tableFontSize = 25


type CssClass
  = Settings
  | GroupTitle
  | GroupCss
  | RowItem
  | Searchbar
  | Button
  | Search

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ class GroupTitle(
    [ fontSize (40 |> px)
    , color Color.c_offWhite
    ])
  , class GroupCss(
    [ width (50 |> pct)
    ])
  , class RowItem(
    [ hover [backgroundColor Color.c_hovering]
    , backgroundColor Color.c_games_table
    ])
  , class Settings(
    [ width (100 |> pct)
    , displayFlex
    ])
  , Css.Elements.table(
    [ width (100 |> pct)
    , fontSize (tableFontSize |> px)
    ])
  , class Search (
    [ width (50 |> pct)
    , marginLeft (10 |> pct)
    , marginTop (46 |> px)
    ])
  , class Searchbar(
    [ fontSize (25 |> px)
    ])
  , class Button(
    [ position relative
    , top (1 |> px)
    , width (32 |> px)
    , height (32 |> px)
    ])
  ]
