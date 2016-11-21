port module Stylesheets exposing (..)

import Css.File exposing (..)
import DashboardCss
import Html exposing (div)
import Html.App
import MainCss
import Minimap.Css
import NavbarCss
import TagScroller.Css
import Timeline.Css

port files : CssFileStructure -> Cmd msg

(=>) = (,)

cssFiles : CssFileStructure
cssFiles =
    toFileStructure
      [ "dashboard.css" => compile
        [ DashboardCss.css
        , Minimap.Css.css
        , Timeline.Css.css
        , TagScroller.Css.css
        ]
      , "navbar.css" => compile
        [ NavbarCss.css
        ]
      , "index.css" => compile
        [ MainCss.css
        ]
      ]


main : Program Never
main =
    Html.App.program
        { init = ( (), files cssFiles )
        , view = \_ -> (div [] [])
        , update = \_ _ -> ( (), Cmd.none )
        , subscriptions = \_ -> Sub.none
        }