module TagScroller.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import TagScroller.Models exposing (Model)
import TagScroller.Messages exposing (Msg(..))

view : Model -> Html Msg
view model =
  let
    tags = model.tags
         |> List.map (\tag ->
           div [ class "tag"
               , onClick <| TagClick tag.timestamp
               ]
             [ text << toString <| tag.tagType
             ]
         )
  in
    div [ class "tag-scroller" ]
      tags
