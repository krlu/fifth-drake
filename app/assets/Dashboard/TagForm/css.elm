module TagForm.Css exposing (..)
import CssColors as Color
import Css exposing (..)
import Css.Namespace
import Minimap.Css
import StyleUtils

namespace : String
namespace = "tagForm"

tagFormHeight : Float
tagFormHeight = 100

type CssClass = TagFormCss

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) TagFormCss (
    [ width (10 |> px)
    , height (10 |> px)
    , overflowY auto
    , backgroundColor Color.c_darkGray
    , property "float" "left"
    ] ++ StyleUtils.userSelect "none")
  ]
