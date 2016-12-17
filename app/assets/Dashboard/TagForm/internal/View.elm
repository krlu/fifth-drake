module TagForm.Internal.View exposing (..)

import TagForm.Css exposing (CssClass(TagForm), namespace)
import Html exposing (..)
import Html.CssHelpers exposing (withNamespace)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onClick, onInput)
import TagForm.Types exposing (..)
import String
import List exposing (..)

{id, class, classList} = withNamespace namespace

view : Model -> Html Msg
view m =
  form [ class [TagForm] ]
                [ p [] [ input [ placeholder "Title", onInput CreateTitle ] [] ]
                , p [] [ input [ placeholder "Category", onInput CreateCategory ] [] ]
                , p [] [ textarea  [ placeholder "Description", onInput CreateDescription ] [] ]
                , p [] [ input [ placeholder "Players", onInput AddPlayers ] [] ]
                , p [] [ button [ onClick CancelForm ] [ text "cancel" ],
                         button [ onClick SaveTag] [ text "save" ]
                       ]
                ]

