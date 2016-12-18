module TagCarousel.Internal.View exposing (..)

import Html exposing (..)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (onClick)
import TagCarousel.Css exposing (CssClass(Tag, TagCarousel), namespace)
import TagCarousel.Types exposing (Msg(..), Model)

{id, class, classList} = withNamespace namespace

view : Model -> Html Msg
view model =
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
  in
    ol [ class [TagCarousel] ]
      tags
