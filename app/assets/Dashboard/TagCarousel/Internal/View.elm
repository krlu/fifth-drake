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
    tags = model.tags
         |> List.map (\tag ->
           div [ class [Tag]
               , onClick <| TagClick tag.timestamp
               ]
             [ p [] [text tag.title]
             , p [] [text << toString <| tag.category]
             ]
         )
  in
    div [ class [TagCarousel] ]
      tags
