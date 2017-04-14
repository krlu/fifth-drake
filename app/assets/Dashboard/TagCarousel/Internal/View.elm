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
    groupFilteredTags = List.filter (tagInAllGroups model.groupFilters) model.tags
    (filteredTags, filterCss) =
      case model.filteredByAuthor of
        True -> (List.filter (\tag -> tag.author.id == currentUserId) groupFilteredTags, SelectedFilter)
        False -> (groupFilteredTags, UnselectedFilter)
    tags = List.sortBy .timestamp filteredTags
           |> List.map (\tag ->
              tagHtml tag permissions currentUserId model.lastClickedTag model.tagForm.active model.deleteTagButton)
    tagsShare = List.sortBy .timestamp model.tags
                |> List.filter (\tag -> tag.author.id == currentUserId)
                |> List.map (\tag -> tagShareModeHtml tag permissions model.tagForm.active)
    tagFormView = tagFormHtml model players
    carouselCss =
      if model.tagForm.active then
        [TagCarousel, MinimizedCarousel]
      else
        [TagCarousel]
    authorFilterHtml = buildFilterHtml FilterByAuthor "My Tags" filterCss
    groupFilterHtml =
      List.map (\perm ->
        buildFilterHtml (FilterByGroup perm.groupId) "Group Tags"
        <| groupFilterCss perm.groupId model.groupFilters) permissions
    (shareFormButtonLabel, tagsHtml, filterHtml) =
      case model.isShareForm of
       True ->
        ("Done", tagsShare, [])
       False -> ("Share Tags", tags, [authorFilterHtml] ++ groupFilterHtml)
    carouselControlsHtml =
      case (List.length permissions) == 0 of
        False ->
          ([ div
           [class [ShareTagCss, CarouselControlCss]
           , onClick ToggleCarouselForm]
           [ text shareFormButtonLabel
           ]
          ] ++ filterHtml)
        True -> [ div [class [CarouselControlCss]] []]
  in
    div [class [CarouselContainer]]
    [ div [class [CarouselControls]]
      carouselControlsHtml
    , div
      [ id [TagDisplay] ]
      [ div [ class carouselCss ]
        tagsHtml
      , tagFormView
      ]
    ]

groupFilterCss : GroupId -> List GroupId -> CssClass
groupFilterCss groupId filters =
  case List.member groupId filters of
    True -> SelectedFilter
    False -> UnselectedFilter

tagInAllGroups : List GroupId -> TagCarousel.Types.Tag -> Bool
tagInAllGroups groupIds tag =
  not
  <| List.member False
  <| List.map (\id -> List.member id tag.authorizedGroups) groupIds

buildFilterHtml : Msg -> String -> CssClass -> Html Msg
buildFilterHtml action label filterCss =
  div
  [class [FilterTagCss, filterCss, CarouselControlCss]
  , onClick action
  ]
  [ text label
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


tagShareModeHtml : TagCarousel.Types.Tag -> List Permission -> Bool -> Html Msg
tagShareModeHtml tag permissions formActive =
  let
    tagCss = [Tag]
    isShared =
      List.member True <| List.map (\perm -> List.member perm.groupId tag.authorizedGroups) permissions
    selectedCss =
      case isShared of
        True -> tagCss ++ [HighlightSharedTag]
        False -> tagCss ++ [UnsharedTag]
    selectedAndAltCss =
      case formActive of
        True -> selectedCss ++ [AltTag]
        False -> selectedCss
  in
    li
      [ class selectedAndAltCss ]
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

tagHtml : TagCarousel.Types.Tag -> List Permission -> UserId -> TagId-> Bool -> String -> Html Msg
tagHtml tag permissions currentUserId lastClickedTag formActive deleteButton =
  let
    levels =
      List.map (\perm -> perm.level)
      <| List.filter (\element -> List.member element.groupId tag.authorizedGroups) permissions
    tagCss = [Tag]
    selectedCss =
      case (tag.id == lastClickedTag) of
        True -> tagCss ++ [SelectedTag]
        False -> tagCss
    selectedAndAltCss =
      case formActive of
        True -> selectedCss ++ [AltTag]
        False -> selectedCss
    deleteHtml =
      [ p [class [DeleteButtonCss], onClick (DeleteTag tag.id)]
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
        , onClick <| TagClick (tag.timestamp, tag.id)
        , onMouseOver <| HighlightPlayers tag.players
        , onMouseLeave UnhighlightPlayers
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
