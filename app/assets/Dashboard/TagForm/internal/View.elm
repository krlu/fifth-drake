module TagForm.Internal.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onClick, onInput)
import TagForm.Types exposing (..)
import String

update (NewContent content) oldContent =
  content

view : Html Msg
view =
  let
    tagForm = form []
                [ input [ placeholder "Title", onInput NewContent ] []
                , input [ placeholder "Category", onInput NewContent ] []
                , input [ placeholder "Description", onInput NewContent ] []
                , input [ placeholder "Players", onInput NewContent ] []
                ]
  in
    tagForm
