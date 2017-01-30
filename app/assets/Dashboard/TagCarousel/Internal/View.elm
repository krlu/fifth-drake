module TagCarousel.Internal.View exposing (..)

import Css exposing (backgroundColor)
import GameModel exposing (Player, PlayerId, Timestamp)
import Html exposing (..)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (onClick, onMouseLeave, onMouseOver)
import TagCarousel.Css exposing (CssClass(..), namespace)
import TagCarousel.Types exposing (Model, Msg(..), TagId)
import Html.Attributes exposing (href, placeholder, rel, src, style, type_)
import Html.Events exposing (onClick, onInput)

{id, class, classList} = withNamespace namespace

view : Model -> List (PlayerId, String) -> Html Msg
view model players =
  let
    tags = List.sortBy .timestamp model.tags
         |> List.map (\tag -> tagHtml tag model.lastClickedTime model.tagForm.active model.deleteTagButton )
    checkBoxes = players |> List.map (\playerData -> playerDataToHtml playerData)
    tagFormView = tagFormHtml model players
    carouselCss =
      if model.tagForm.active then
        [TagCarousel, MinimizedCarousel]
      else
        [TagCarousel]
  in
    div [ id [TagDisplay] ]
    [ ol [ class carouselCss ] tags
    , tagFormView
    ]


tagFormHtml : Model -> List (PlayerId, String) -> Html Msg
tagFormHtml model players =
  let
    checkBoxes = players |> List.map (\playerData -> playerDataToHtml playerData)
  in
    if model.tagForm.active then
      div [ class [TagFormCss] ]
      [
        div [ id [TagFormTextInput] ]
        [ input [ placeholder "Title", onInput CreateTitle, id [TagFormTextBox] ] []
        , input [ placeholder "Category", onInput CreateCategory, id [TagFormTextBox] ] []
        , textarea [ placeholder "Description", onInput CreateDescription, id [TagFormTextArea] ] []
        ]
      , div [ id [PlayerCheckboxes] ] (
        [ div [ id [PlayersInvolved] ] [text "Players Involved"]
        ]
        ++ checkBoxes
        )
      , p [ id [SaveOrCancelForm] ]
          [ button [ onClick SwitchForm ] [ text "cancel" ]
          , button [ onClick SaveTag] [ text "save" ]
          ]
      ]
    else
      div [ id [AddTagButton], onClick SwitchForm]
      [ img [src model.tagButton] []
      ]


tagHtml : TagCarousel.Types.Tag -> Timestamp -> Bool -> String -> Html Msg
tagHtml tag lastClickedTimeStamp formActive deleteButton =
  let
    tagCss = [Tag]
    selectedCss =
      case (tag.timestamp == lastClickedTimeStamp) of
        True -> tagCss ++ [SelectedTag]
        False -> tagCss
    selectedAndAltCss =
      case formActive of
        True -> selectedCss ++ [AltTag]
        False -> selectedCss
  in
    li [ class selectedAndAltCss
       , onClick <| TagClick tag.timestamp
       ]
      [ div []
          [ p [] [text tag.title]
          , p [] [text << toString <| tag.category]
          , p [] [text tag.description]
          ]
      , p [class [DeleteButtonCss], onClick (DeleteTag tag.id)]
          [ img [src deleteButton] []
          ]
      ]


playerDataToHtml: (PlayerId, String) -> Html Msg
playerDataToHtml (id, ign) = checkbox (AddPlayers id) ign


checkbox : msg -> String -> Html msg
checkbox msg name =
  label [ id [CheckboxCss] ]
    [ input [ type_ "checkbox", onClick msg ] []
    , text name
    ]
