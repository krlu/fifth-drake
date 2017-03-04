module HomeCss exposing (..)

import Css exposing (..)
import Css.Namespace

namespace : String
namespace = "home"


type CssClass
  = Home
  | ListElement

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [(.) Home(
    [ width (100 |> pct)
    , overflowY scroll
    ])
  ,(.) ListElement(
    [ marginTop (50 |> px)
    , marginLeft (50 |> px)
    , fontSize (25 |> px)
    ])
  ]
