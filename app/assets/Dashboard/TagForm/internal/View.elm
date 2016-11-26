module TagForm.Internal.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (placeholder)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (onClick, onInput)
import TagForm.Types exposing (..)
import String

view : Model -> Html Msg
view model =
  let
    tagForm = form []
                [ input [ placeholder "Title", onInput TagSave ] []
                , input [ placeholder "Category", onInput TagSave ] []
                , input [ placeholder "Description", onInput TagSave ] []
                , input [ placeholder "Players", onInput TagSave ] []
                ]
  in
    tagForm
