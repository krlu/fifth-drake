module TagCarousel.Internal.View exposing (..)

import GameModel exposing (Player)
import Html exposing (..)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (onClick)
import TagCarousel.Css exposing (CssClass(Tag, TagCarousel, TagFormCss), namespace)
import TagCarousel.Types exposing (Model, Msg(..))
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onClick, onInput)

{id, class, classList} = withNamespace namespace

view : Model -> List Player -> Html Msg
view model players =
  let
    tags = List.sortBy .timestamp model.tags
         |> List.map (\tag ->
           li [ class [Tag]]
             [div [ onClick <| TagClick tag.timestamp]
                  [ p [] [text tag.title]
                  , p [] [text << toString <| tag.category]
                  ]
             , p [] [ button [ onClick (DeleteTag tag.id)] [text "delete"]]
             ]
         )
    tagFormView = if model.tagForm.active == True then
                 div [ class [TagFormCss] ]
                             [ p [] [ input [ placeholder "Title", onInput CreateTitle ] [] ]
                             , p [] [ input [ placeholder "Category", onInput CreateCategory ] [] ]
                             , p [] [ textarea  [ placeholder "Description", onInput CreateDescription ] [] ]
                             , p [] [ input [ placeholder "Players", onInput AddPlayers ] [] ]
                             , p [] [ button [ onClick SwitchForm ] [ text "cancel" ],
                                      button [ onClick SaveTag] [ text "save" ]
                                    ]
                             ]
              else
                button [ onClick SwitchForm] [ text "create new tag" ]
  in
    div [] [ ol [ class [TagCarousel] ] tags
           , tagFormView
    ]
