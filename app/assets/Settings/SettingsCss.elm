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
buttonSize = 34

searchBarWidth : Float
searchBarWidth = 562

searchResultFont : Float
searchResultFont = 25

searchResultHeight : Float
searchResultHeight = 6 -- pct

backgroundPaneHeight : Float
backgroundPaneHeight = 500

groupContainerWidth : Float
groupContainerWidth = 600

groupLeftMargin : Float
groupLeftMargin = 50

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
  | AddButton
  | UsersBackgroundPane
  | DeleteButtonCss
  | GroupRow
  | GroupCell
  | CreateButton

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ class GroupTitle(
    [ fontSize (groupTitleSize |> px)
    , color Color.c_offWhite
    ])
  , class GroupCss(
    [ width (groupContainerWidth |> px)
    , marginLeft (groupLeftMargin |> px)
    ])
  , class Settings(
    [ width (100 |> pct)
    , displayFlex
    ])
  , class Searchbar(
    [ fontSize (searchBarFont |> px)
    , width (searchBarWidth |> px)
    ])
  , class AddButton(
    [ position relative
    , top (buttonTopPosition |> px)
    , width (buttonSize |> px)
    , height (buttonSize |> px)
    ])
  , class UsersBackgroundPane(
    [ backgroundColor Color.c_navBar
    , width (100 |> pct)
    , height (backgroundPaneHeight |> px)
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
  , class CreateButton(
    [ width (51 |> px)
    , height (26 |> px)
    , fontSize (18 |> px)
    , borderRadius (6 |> px)
    , backgroundColor Color.c_create_button
    , hover [ backgroundColor Color.c_hovering ]
    , cursor pointer
    , textAlign center
    , lineHeight (26 |> px)
    ])
  ]
