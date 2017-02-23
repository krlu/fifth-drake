port module Stylesheets exposing (..)

import Controls.Css
import Css.File exposing (..)
import DashboardCss
import Graph.Css
import Html exposing (div)
import MainCss
import Minimap.Css
import NavbarCss
import TagCarousel.Css
import Platform
import PlayerDisplay.Css
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
        , TagCarousel.Css.css
        , PlayerDisplay.Css.css
        , TeamDisplay.Css.css
        , Graph.Css.css
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
