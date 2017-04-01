module TagCarousel.Internal.View exposing (view)

import Css exposing (backgroundColor)
import GameModel exposing (Player, PlayerId, Timestamp)
import Html exposing (..)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (onClick, onMouseLeave, onMouseOver)
import TagCarousel.Css exposing (CssClass(..), namespace)
import TagCarousel.Types exposing (Model, Msg(..), TagId)
import Html.Attributes exposing (href, placeholder, defaultValue, rel, src, style, type_, for)
import Html.Events exposing (onClick, onInput)
import SettingsTypes exposing (GroupId, UserId)
import Types exposing (Permission)

{id, class, classList} = withNamespace namespace

view : Model -> List Permission -> UserId -> List (PlayerId, String, String, String) -> Html Msg
view model permissions currentUserId players =
  let
    tags = List.sortBy .timestamp model.tags
           |> List.map (\tag ->
              tagHtml tag permissions currentUserId model.lastClickedTime model.tagForm.active model.deleteTagButton)
    tagsShare = List.sortBy .timestamp model.tags
                |> List.filter (\tag -> tag.author.id == currentUserId)
                |> List.map (\tag -> tagShareModeHtml tag permissions)
    tagFormView = tagFormHtml model players
    carouselCss =
      if model.tagForm.active then
        [TagCarousel, MinimizedCarousel]
      else
        [TagCarousel]
    (shareFormButtonLabel, tagsHtml) =
      case model.isShareForm of
       True ->
        ("Done", tagsShare)
       False -> ("Share Tags", tags)
  in
    div [class [CarouselContainer]]
    [ div
      [class [ShareTagCss]
      , onClick ToggleCarouselForm]
      [ text shareFormButtonLabel
      ]
    , div
      [ id [TagDisplay] ]
      [ div [ class carouselCss ]
        tagsHtml
      , tagFormView
      ]
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
            checkBoxes ++
            [ div
              [ class [CheckboxItem] ]
              [ input
                 [ type_ "checkbox"
                 , onClick UpdateShare
                 ]
                 []
              , label
                [ class [CheckboxLabel]
                ]
                [ text "Share with group"
                ]
              ]
            ]
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


tagShareModeHtml : TagCarousel.Types.Tag -> List Permission -> Html Msg
tagShareModeHtml tag permissions =
  let
    tagCss = [Tag]
    isShared =
      List.member True <| List.map (\perm -> List.member perm.groupId tag.authorizedGroups) permissions
    selectedCss =
      case (Debug.log "" isShared) of
        True -> tagCss ++ [HighlightSharedTag]
        False -> tagCss ++ [UnsharedTag]
  in
    li
      [ class selectedCss ]
      [ div
        [ class [ TagClickableArea ]
        , onClick (ToggleShare tag.id)
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
      ]

tagHtml : TagCarousel.Types.Tag -> List Permission -> UserId -> Timestamp -> Bool -> String -> Html Msg
tagHtml tag permissions currentUserId lastClickedTimeStamp formActive deleteButton =
  let
    levels =
      List.map (\perm -> perm.level)
      <| List.filter (\element -> List.member element.groupId tag.authorizedGroups) permissions
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
      case (tag.author.id == currentUserId, List.member "admin" levels, List.member "owner" levels) of
        (False, False, False) -> []
        _ ->
          [p [class [DeleteButtonCss], onClick (DeleteTag tag.id)]
            [ img
              [src deleteButton]
              []
            ]
          ]
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
