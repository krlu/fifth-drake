module TagScroller.Internal.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import TagScroller.Types exposing (Msg(..), Model)

view : Model -> Html Msg
view model =
  let
    tags = model.tags
         |> List.map (\tag ->
           div [ class "tag"
               , onClick <| TagClick tag.timestamp
               ]
             [ p [] [text tag.title]
             , p [] [text << toString <| tag.category]
             ]
         )
  in
    div [ class "tag-scroller" ]
      tags
