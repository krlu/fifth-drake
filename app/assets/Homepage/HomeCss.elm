module HomeCss exposing (..)

import Css exposing (..)
import Css.Namespace

namespace : String
namespace = "home"


type CssClass
  = Home

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [(.) Home(
    [ width (200 |> px)
    , height (30 |> px)
    , fontSize (25 |> px)
    ])
  ]
