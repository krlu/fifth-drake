module SettingsCss exposing (..)

import Css exposing (..)
import Css.Elements exposing (table, td, tr)
import Css.Namespace
import CssColors as Color

namespace : String
namespace = "settings"

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [
  ]
