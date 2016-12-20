port module Stylesheets exposing (..)

import Controls.Css
import Css.File exposing (..)
import DashboardCss
import Html exposing (div)
import MainCss
import Minimap.Css
import NavbarCss
import Platform
import PlayerDisplay.Css
import TagScroller.Css
import TeamDisplay.Css

port files : CssFileStructure -> Cmd msg

(=>) = (,)

cssFiles : CssFileStructure
cssFiles =
    toFileStructure
      [ "dashboard.css" => compile
        [ Controls.Css.css
        , DashboardCss.css
        , Minimap.Css.css
        , PlayerDisplay.Css.css
        , TagScroller.Css.css
        , TeamDisplay.Css.css
        ]
      , "navbar.css" => compile
        [ NavbarCss.css
        ]
      , "index.css" => compile
        [ MainCss.css
        ]
      ]


main : CssCompilerProgram
main =
  compiler files cssFiles
