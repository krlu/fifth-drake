module TagForm.Internal.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onClick, onInput)
import TagForm.Types exposing (..)
import String

view : Model -> Html Msg
view m =
  let
    tagForm = form []
                [ p [] [ input [ placeholder "Title", onInput CreateTitle ] [] ]
                , p [] [ input [ placeholder "Category", onInput CreateCategory ] [] ]
                , p [] [ input [ placeholder "Description", onInput CreateDescription ] [] ]
                , p [] [ input [ placeholder (toString m.timestamp)] [] ]
                , p [] [ input [ placeholder "Players", onInput AddPlayers ] [] ]
                , p [] [ button [ onClick CancelForm ] [ text "cancel" ],
                         button [ onClick SaveTag ] [ text "save" ]
                       ]
                ]
  in
    tagForm
