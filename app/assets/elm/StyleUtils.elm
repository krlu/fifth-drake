module StyleUtils exposing (..)

import Html.Attributes
import Css

styles = Css.asPairs >> Html.Attributes.style

