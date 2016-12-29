module TagCarousel.Internal.View exposing (..)

import Dialog
import GameModel exposing (Player, PlayerId)
import Html exposing (..)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (onClick)
import TagCarousel.Css exposing (CssClass(..), namespace)
import TagCarousel.Types exposing (Model, Msg(..))
import Html.Attributes exposing (href, placeholder, rel, style, type_)
import Html.Events exposing (onClick, onInput)

{id, class, classList} = withNamespace namespace

view : Model -> List (PlayerId, String) -> Html Msg
view model players =
  let
    tags = List.sortBy .timestamp model.tags
         |> List.map (\tag -> tagHtml tag model.lastClickedTagId model.tagForm.active)
    checkBoxes = players |> List.map (\playerData -> playerDataToHtml playerData)
    tagFormView =
      if model.tagForm.active == True then
        div [ class [TagFormCss] ]
        [ p [] [ input [ placeholder "Title", onInput CreateTitle ] [] ]
        , p [] [ input [ placeholder "Category", onInput CreateCategory ] [] ]
        , p [] [ textarea  [ placeholder "Description", onInput CreateDescription ] [] ]
        , p [] checkBoxes
        , p [] [ button [ onClick SwitchForm ] [ text "cancel" ],
                 button [ onClick SaveTag] [ text "save" ]
               ]
        ]
      else
        button [ onClick SwitchForm] [ text "create new tag" ]
    carouselCss =
      if model.tagForm.active == True then
        MinimizedCarousel
      else
        TagCarousel
  in
    div [ id [TagDisplay] ]
    [ ol [ class [carouselCss] ] tags
     , tagFormView
     , bootstrap
    ]


tagHtml: TagCarousel.Types.Tag -> Int -> Bool -> Html Msg
tagHtml tag lastClickedTagId formActive =
  let
    tagCss = if(tag.id == lastClickedTagId) then
               if(formActive == True) then
                 AltSelectedTag
               else
                 SelectedTag
             else
               if(formActive == True) then
                 AltTag
               else
                 Tag
  in
   li [ class [tagCss], onClick <| TagClick tag.timestamp tag.id]
     [div []
          [ p [] [text tag.title]
          , p [] [text << toString <| tag.category]
          , p [] [text tag.description]
          ]
     , p [class [DeleteButtonCss]] [ button [ onClick (DeleteTag tag.id)] [text "delete"]]
     ]


playerDataToHtml: (PlayerId, String) -> Html Msg
playerDataToHtml (id, ign) = p[][ checkbox (AddPlayers id) ign]


checkbox : msg -> String -> Html msg
checkbox msg name =
  label [ class [CheckboxCss] ]
    [ input [ type_ "checkbox", onClick msg ] []
    , text name
    ]

bootstrap : Html msg
bootstrap =
    node "link"
        [ href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"
        , rel "stylesheet"
        ]
        []
