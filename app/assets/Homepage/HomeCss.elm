module HomeCss exposing (..)

import Css exposing (..)
import Css.Namespace

namespace : String
namespace = "home"


type CssClass
  = Home
  | ListItem
  | VodItem

css : Stylesheet
css =
  (stylesheet << Css.Namespace.namespace namespace)
  [(.) Home(
    [ width (100 |> pct)
    , overflowY scroll
    ])
  ,(.) ListItem(
    [ marginTop (50 |> px)
    , marginLeft (50 |> px)
    , fontSize (25 |> px)
    ])
  ,(.) VodItem(
    [ marginLeft (50 |> px)
    ]
  )
  ]
