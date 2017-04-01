module SettingsCss exposing (..)

import Css exposing (..)
import Css.Elements exposing (table, td, tr)
import Css.Namespace
import CssColors as Color

namespace : String
namespace = "settings"

groupTitleSize : Float
groupTitleSize = 4  -- vw

searchMargin : Float
searchMargin = 1 -- vw

searchBarFont : Float
searchBarFont = 2 -- vw

buttonTopPosition : Float
buttonTopPosition = 0.1 -- vw

buttonSize : Float
buttonSize = 2.6 -- vw

searchBarWidth : Float
searchBarWidth = 50 -- vw

searchResultFont : Float
searchResultFont = 2 -- vw

searchResultHeight : Float
searchResultHeight = 6 -- pct

backgroundPaneHeight : Float
backgroundPaneHeight = 50 -- vw

groupContainerWidth : Float
groupContainerWidth = 60 -- vw

groupLeftMargin : Float
groupLeftMargin = 5 -- vw

rowHeight : Float
rowHeight = 3 -- vw

rowLineHeight : Float
rowLineHeight = 3 -- vw

rowBottomBorderWidth : Float
rowBottomBorderWidth = 0.1 -- vw

cellWidth : Float
cellWidth = 38 -- pct

cellFontSize : Float
cellFontSize = 1.5 -- vw

memberCellWidth : Float
memberCellWidth = 10 --pct

createButtonWidth : Float
createButtonWidth = 5 -- vw

createButtonHeight : Float
createButtonHeight = 2 -- vw

createButtonFontSize : Float
createButtonFontSize = 2 -- vw

createButtonBorderRadius : Float
createButtonBorderRadius = 1 -- vw

deleteButtonWidth : Float
deleteButtonWidth = 10 -- vw

deleteButtonHeight : Float
deleteButtonHeight = 4 -- vh

deleteButtonFontSize : Float
deleteButtonFontSize = 1.5 -- vw

deleteButtonBorderRadius : Float
deleteButtonBorderRadius = 1 -- vw

permissionCellMargin : Float
permissionCellMargin = 2 -- vw

type CssClass
  = Settings
  | GroupTitle
  | GroupCss
  | Searchbar
  | AddButton
  | UsersBackgroundPane
  | DeleteUserButton
  | GroupRow
  | GroupCell
  | MemberCell
  | CreateButton
  | DeleteGroupButton
  | PermissionCell

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ class GroupTitle
    [ fontSize (groupTitleSize |> vw)
    , color Color.c_offWhite
    ]
  , class GroupCss
    [ width (groupContainerWidth |> vw)
    , marginLeft (groupLeftMargin |> vw)
    ]
  , class Settings
    [ width (100 |> pct)
    , displayFlex
    ]
  , class Searchbar
    [ fontSize (searchBarFont |> vw)
    , width (searchBarWidth |> vw)
    ]
  , class AddButton
    [ position relative
    , top (buttonTopPosition |> vw)
    , width (buttonSize |> vw)
    , height (buttonSize |> vw)
    ]
  , class UsersBackgroundPane
    [ backgroundColor Color.c_navBar
    , width (100 |> pct)
    , height (backgroundPaneHeight |> vw)
    , overflowY scroll
    ]
  , class DeleteUserButton
    [ display none
    ]
  , class GroupRow
    [ width (100 |> pct)
    , height (rowHeight |> vw)
    , hover
      [ backgroundColor Color.c_hovering
      , children
        [ class DeleteUserButton
          [ cursor pointer
          , displayFlex
          , float right
          , width (0 |> pct)
          ]
        , class PermissionCell
          [ cursor pointer
          , displayFlex
          , marginLeft (permissionCellMargin |> vw)
          , marginRight (permissionCellMargin |> vw)
          ]
        ]
      ]
    , backgroundColor Color.c_games_table
    , displayFlex
    , fontSize (cellFontSize |> vw)
    , borderBottomStyle solid
    , borderBottomWidth (rowBottomBorderWidth |> vw)
    , lineHeight (rowLineHeight |> vw)
    ]
  , class GroupCell
    [ width (cellWidth |> pct)
    ]
  , class MemberCell
    [ width (memberCellWidth |> pct)
    ]
  , class CreateButton
    [ width (createButtonWidth |> vw)
    , height (createButtonHeight |> vw)
    , fontSize (createButtonFontSize |> vw)
    , borderRadius (createButtonBorderRadius |> vw)
    , backgroundColor Color.c_create_button
    , hover [ backgroundColor Color.c_hovering ]
    , cursor pointer
    , textAlign center
    , lineHeight (createButtonHeight |> vw)
    ]
  , class DeleteGroupButton
    [ width (deleteButtonWidth |> vw)
    , height (deleteButtonHeight |> vw)
    , fontSize (deleteButtonFontSize |> vw)
    , borderRadius (deleteButtonBorderRadius |> vw)
    , backgroundColor Color.c_delete_button
    , hover [ backgroundColor Color.c_delete_button_hover]
    , cursor pointer
    , textAlign center
    , lineHeight (deleteButtonHeight |> vw)
    ]
  , class PermissionCell
    [display none
    ]
  ]
