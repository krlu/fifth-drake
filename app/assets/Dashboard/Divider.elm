module Divider exposing (..)

import DashboardCss exposing (CssClass(Hdivider, Vdivider), namespace)
import Html exposing (Html, div)
import Html.CssHelpers exposing (withNamespace)

vertical : Html a
vertical = div [ (withNamespace namespace).class [Vdivider] ] []

horizontal : Html a
horizontal = div [ (withNamespace namespace).class [Hdivider] ] []
