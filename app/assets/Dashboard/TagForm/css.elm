module TagForm.Css exposing (..)
import CssColors as Color
import Css exposing (..)
import Css.Namespace
import Minimap.Css
import StyleUtils

namespace : String
namespace = "tagForm"

type CssClass
  = TagForm | Field

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [ (.) TagForm (
    [ width (10 |> pct)
    , overflowY auto
    , backgroundColor Color.c_darkGray
    , property "float" "left"
    ])
  ]
