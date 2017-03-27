module SettingsCss exposing (..)

import Css exposing (..)
import Css.Elements exposing (table, td, tr)
import Css.Namespace
import CssColors as Color

namespace : String
namespace = "settings"

groupTitleSize : Float
groupTitleSize = 40  -- px

searchMargin : Float
searchMargin = 14 -- px

searchBarFont : Float
searchBarFont = 25 -- px

buttonTopPosition : Float
buttonTopPosition = 1 -- px

buttonSize : Float
buttonSize = 34 -- px

searchBarWidth : Float
searchBarWidth = 500 -- px

searchResultFont : Float
searchResultFont = 25 -- px

searchResultHeight : Float
searchResultHeight = 6 -- pct

backgroundPaneHeight : Float
backgroundPaneHeight = 500 -- px

groupContainerWidth : Float
groupContainerWidth = 750 -- px

groupLeftMargin : Float
groupLeftMargin = 50 -- px

rowHeight : Float
rowHeight = 30 -- px

rowLineHeight : Float
rowLineHeight = 34 -- px

rowBottomBorderWidth : Float
rowBottomBorderWidth = 1 -- px

cellWidth : Float
cellWidth = 38 -- pct

cellFontSize : Float
cellFontSize = 18 -- px

memberCellWidth : Float
memberCellWidth = 10 --pct

createButtonWidth : Float
createButtonWidth = 51 -- px

createButtonHeight : Float
createButtonHeight = 26 -- px

createButtonFontSize : Float
createButtonFontSize = 18 -- px

createButtonBorderRadius : Float
createButtonBorderRadius = 6 -- px

permissionCellMargin : Float
permissionCellMargin = 20 -- px

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
  | MemberCell
  | CreateButton
  | PermissionCell

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
    , overflowY scroll
    ])
  , class DeleteButtonCss(
    [ display none
    ])
  , class GroupRow(
    [ width (100 |> pct)
    , height (rowHeight |> px)
    , hover
      [ backgroundColor Color.c_hovering
      , children
        [ class DeleteButtonCss
          [ cursor pointer
          , displayFlex
          , float right
          , width (0 |> pct)
          ]
        , class PermissionCell
          [ cursor pointer
          , displayFlex
          , marginLeft (permissionCellMargin |> px)
          , marginRight (permissionCellMargin |> px)
          ]
        ]
      ]
    , backgroundColor Color.c_games_table
    , displayFlex
    , fontSize (cellFontSize |> px)
    , borderBottomStyle solid
    , borderBottomWidth (rowBottomBorderWidth |> px)
    , lineHeight (rowLineHeight |> px)
    ])
  , class GroupCell(
    [ width (cellWidth |> pct)
    ])
  , class MemberCell(
    [ width (memberCellWidth |> pct)
    ])
  , class CreateButton(
    [ width (createButtonWidth |> px)
    , height (createButtonHeight |> px)
    , fontSize (createButtonFontSize |> px)
    , borderRadius (createButtonBorderRadius |> px)
    , backgroundColor Color.c_create_button
    , hover [ backgroundColor Color.c_hovering ]
    , cursor pointer
    , textAlign center
    , lineHeight (createButtonHeight |> px)
    ])
  , class PermissionCell(
    [display none
    ])
  ]
