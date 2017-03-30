module TagCarousel.Internal.View exposing (..)

import Css exposing (backgroundColor)
import GameModel exposing (Player, PlayerId, Timestamp)
import Html exposing (..)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (onClick, onMouseLeave, onMouseOver)
import TagCarousel.Css exposing (CssClass(..), namespace)
import TagCarousel.Types exposing (Model, Msg(..), TagId)
import Html.Attributes exposing (href, placeholder, defaultValue, rel, src, style, type_, for)
import Html.Events exposing (onClick, onInput)
import SettingsTypes exposing (UserId)

{id, class, classList} = withNamespace namespace

view : Model -> UserId -> List (PlayerId, String, String, String) -> Html Msg
view model userId players =
  let
    tags = List.sortBy .timestamp model.tags
         |> List.map (\tag -> tagHtml tag userId model.lastClickedTime model.tagForm.active model.deleteTagButton )
    tagFormView = tagFormHtml model players
    carouselCss =
      if model.tagForm.active then
        [TagCarousel, MinimizedCarousel]
      else
        [TagCarousel]
  in
    div
      [ id [TagDisplay] ]
      [ ol
          [ class carouselCss ]
          tags
      , tagFormView
      ]


tagFormHtml : Model -> List (PlayerId, String, String, String) -> Html Msg
tagFormHtml model players =
  let
    checkBoxes = players |> List.map (\playerData -> playerDataToHtml playerData)
  in
    if model.tagForm.active then
      div
        [ class [TagFormCss] ]
        [
          div
            [ id [TagFormTextInput] ]
            [ input
              [ placeholder "Title"
              , onInput CreateTitle
              , class [TagFormTextBox]
              ]
              []
            , select
              [ placeholder "Category"
              , defaultValue "Objective"
              , onInput CreateCategory
              , class [TagFormTextBox]
              ]
              [ option
                [id "Objective"]
                [text "Objective"]
              , option
                [id "TeamFight"]
                [text "TeamFight"]
              ]
            , textarea
              [ placeholder "Description"
              , onInput CreateDescription
              , class [TagFormTextArea]
              ]
              []
            ]
        , div [ class [PlayerCheckboxes] ]
          ( [ div
              [ class [PlayersInvolved] ]
              [ text "Players Involved" ]
            ] ++
            checkBoxes
          )
        , div
          [ id [SaveOrCancelForm] ]
          [ button
            [ onClick SwitchForm ]
            [ text "cancel" ]
          , button
            [ onClick SaveTag]
            [ text "save" ]
          ]
        ]
    else
      div
        [ id [AddTagButton]
        , onClick SwitchForm
        ]
        [ img
            [ src model.tagButton
            , class [PlusImage]
            ]
            []
        ]


tagHtml : TagCarousel.Types.Tag -> UserId -> Timestamp -> Bool -> String -> Html Msg
tagHtml tag userId lastClickedTimeStamp formActive deleteButton =
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
    deleteHtml =
      case tag.author.id == userId of
        True ->
          [p [class [DeleteButtonCss], onClick (DeleteTag tag.id)]
            [ img
              [src deleteButton]
              []
            ]
          ]
        False -> []
  in
    li
      [ class selectedAndAltCss ]
      ([ div
        [ class [ TagClickableArea ]
        , onClick <| TagClick tag.timestamp
        ]
        [ p []
          [text tag.title]
        , p []
          [text tag.category]
        , p []
          [text tag.description]
        , p []
          [text ("- " ++ tag.author.firstName ++ " " ++ tag.author.lastName)]
        ]
      ] ++ deleteHtml)


playerDataToHtml: (PlayerId, String, String, String) -> Html Msg
playerDataToHtml (id, ign, champName, champImage) = checkbox (AddPlayers id) champName champImage


checkbox : msg -> String -> String -> Html msg
checkbox msg champName champImage =
  div
    [ class [CheckboxItem] ]
    [ input
        [ type_ "checkbox"
        , onClick msg
        , id champName
        ]
        []
    , label
       [ class [CheckboxLabel]
       , for champName
       ]
       [ img
          [src champImage
          , class [LabelImage]
          ]
          []
       ]
    ]


