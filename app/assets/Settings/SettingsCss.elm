module SettingsCss exposing (..)

import Css exposing (..)
import Css.Elements exposing (table, td, tr)
import Css.Namespace
import CssColors as Color

namespace : String
namespace = "settings"

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

searchBarWidth : Float
searchBarWidth = 94 -- pct

searchResultFont : Float
searchResultFont = 25

searchResultHeight : Float
searchResultHeight = 6 -- pct

backgroundPaneWidth : Float
backgroundPaneWidth = 90 -- pct

groupContainerWidth : Float
groupContainerWidth = 50 -- pct

groupLeftMargin : Float
groupLeftMargin = groupContainerWidth/100 * (100 - backgroundPaneWidth) --pct

rowWidth : Float
rowWidth = 6 -- pct

cellWidth : Float
cellWidth = 48 -- pct

cellFontSize : Float
cellFontSize = 25

type CssClass
  = Settings
  | GroupTitle
  | GroupCss
  | Searchbar
  | Button
  | UsersBackgroundPane
  | DeleteButtonCss
  | GroupRow
  | GroupCell

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ class GroupTitle(
    [ fontSize (groupTitleSize |> px)
    , color Color.c_offWhite
    ])
  , class GroupCss(
    [ width (groupContainerWidth |> pct)
    , marginLeft (groupLeftMargin |> pct)
    ])
  , class Settings(
    [ width (100 |> pct)
    , displayFlex
    ])
  , class Searchbar(
    [ fontSize (searchBarFont |> px)
    , width (searchBarWidth |> pct)
    ])
  , class Button(
    [ position relative
    , top (buttonTopPosition |> px)
    , width (buttonSize |> px)
    , height (buttonSize |> px)
    ])
  , class UsersBackgroundPane(
    [ backgroundColor Color.c_navBar
    , width (backgroundPaneWidth |> pct)
    , height (50 |> pct)
    ])
  , class DeleteButtonCss(
    [ display none
    ])
  , class GroupRow(
    [ width (100 |> pct)
    , height (rowWidth |> pct)
    , hover
      [ backgroundColor Color.c_hovering
      , children
        [ class DeleteButtonCss
          [ cursor pointer
          , displayFlex
          , float right
          , width (0 |> pct)
          ]
        ]
      ]
    , backgroundColor Color.c_games_table
    , displayFlex
    , fontSize (cellFontSize |> px)
    ])
  , class GroupCell(
    [ width (cellWidth |> pct)
    ])
  ]
