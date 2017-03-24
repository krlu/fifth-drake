module SettingsCss exposing (..)

import Css exposing (..)
import Css.Elements exposing (table, td, tr)
import Css.Namespace
import CssColors as Color

namespace : String
namespace = "settings"

tableFontSize : Float
tableFontSize = 25

groupTitleSize : Float
groupTitleSize = 40

searchMargin : Float
searchMargin = 14

searchBarFont : Float
searchBarFont = 25

buttonTopPosition : Float
buttonTopPosition = 1

buttonSize : Float
buttonSize = 32

searchResultFont : Float
searchResultFont = 25

searchResultHeight : Float
searchResultHeight = 6 -- pct

groupLeftMargin : Float
groupLeftMargin = 50/100 * (100 - 90) --pct

type CssClass
  = Settings
  | GroupTitle
  | GroupCss
  | Searchbar
  | Button
  | Search
  | UsersBackgroundPane
  | SearchResult
  | AddUser
  | UserContent

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ class GroupTitle(
    [ fontSize (groupTitleSize |> px)
    , color Color.c_offWhite
    ])
  , class GroupCss(
    [ width (50 |> pct)
    , marginLeft (groupLeftMargin |> pct)
    ])
  , Css.Elements.tr(
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
    , top (searchMargin |> px)
    , position relative
    ])
  , class Searchbar(
    [ fontSize (searchBarFont |> px)
    ])
  , class Button(
    [ position relative
    , top (buttonTopPosition |> px)
    , width (buttonSize |> px)
    , height (buttonSize |> px)
    ])
  , class UsersBackgroundPane(
    [ backgroundColor Color.c_navBar
    , width (90 |> pct)
    , height (50 |> pct)
    ])
  , class SearchResult(
    [ hover [backgroundColor Color.c_hovering]
    , backgroundColor Color.c_search_result
    , width (100 |> pct)
    , height (searchResultHeight |> pct)
    , fontSize (searchResultFont |> px)
    ])
  , class AddUser(
    [ position relative
    , float right
    ])
  , class UserContent(
    [ position relative
    , float left
    ])
  ]
