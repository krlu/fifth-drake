module TagCarousel.Internal.View exposing (view)

import Css exposing (backgroundColor)
import GameModel exposing (Player, PlayerId, Timestamp)
import Html exposing (..)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (onClick, onMouseLeave, onMouseOver)
import String
import TagCarousel.Css exposing (CssClass(..), namespace)
import TagCarousel.Types exposing (Model, Msg(..), Tag, TagForm, TagId)
import Html.Attributes exposing (checked, defaultValue, for, href, placeholder, rel, src, style, type_, value)
import Html.Events exposing (onClick, onInput)
import SettingsTypes exposing (GroupId, UserId)
import Types exposing (Permission)

{id, class, classList} = withNamespace namespace

view : Model -> List Permission -> UserId -> List (PlayerId, String, String, String) -> Html Msg
view model permissions currentUserId players =
  let

  {------------ Apply filters to list of tags -------------}

    autoFilteredTags =
      case model.showAutoTags of
        True -> model.tags
        False -> List.filter (\tag -> not <| String.contains "auto" tag.id) model.tags
    groupFilteredTags = List.filter (tagInAllGroups model.groupFilters) autoFilteredTags
    tags = List.sortBy .timestamp filteredTags
           |> List.map (\tag ->
              tagHtml tag permissions currentUserId model.lastClickedTag
                model.tagForm.active model.deleteTagButton model.editTagButton)
    tagsShare = List.sortBy .timestamp model.tags
                |> List.filter (\tag -> tag.author.id == currentUserId)
                |> List.map (\tag -> tagShareModeHtml tag permissions model.tagForm.active)

    {----------------- Generate HTML/CSS elements for Tag Carousel -------------------}

    (filteredTags, authorFilterCss) =
      case model.filteredByAuthor of
        True -> (List.filter (\tag -> tag.author.id == currentUserId) groupFilteredTags, SelectedFilter)
        False -> (groupFilteredTags, UnselectedFilter)
    (autoFilteredCss, autoFilteredLabel) =
      case model.showAutoTags of
        True -> (UnselectedFilter, "Hide Auto-Tags")
        False -> (SelectedFilter, "Show Auto-Tags")
    tagFormView = tagFormHtml model players
    carouselCss =
      if model.tagForm.active then
        [TagCarousel, MinimizedCarousel]
      else
        [TagCarousel]
    autoTagsFilterHtml = buildFilterHtml ToggleShowTags autoFilteredLabel [("width", "11vw")] autoFilteredCss
    authorFilterHtml = buildFilterHtml FilterByAuthor "My Tags" [] authorFilterCss
    groupFilterHtml =
      List.map (\perm ->
        buildFilterHtml (UpdateGroupFilters perm.groupId) "Group Tags" []
        <| groupFilterCss perm.groupId model.groupFilters) permissions
    (shareFormButtonLabel, tagsHtml, filterHtml) =
      case model.isShareForm of
       True ->
        ("Done", tagsShare, [])
       False -> ("Share Tags", tags, [autoTagsFilterHtml, authorFilterHtml] ++ groupFilterHtml)
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


{------------ Carousel Filter functions --------------}

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

buildFilterHtml : Msg -> String -> List (String, String) -> CssClass -> Html Msg
buildFilterHtml action label styles filterCss =
  div
  [class [FilterTagCss, filterCss, CarouselControlCss]
  , onClick action
  , style styles
  ]
  [ text label
  ]


{-------------- TagForm Html functions --------------}

tagFormHtml : Model -> List (PlayerId, String, String, String) -> Html Msg
tagFormHtml model players =
  let
    tagForm = model.tagForm
    x = Debug.log "" tagForm.selectedIds
    checkBoxes = players |> List.map (\playerData -> playerDataToHtml playerData tagForm.selectedIds)
  in
    if tagForm.active then
      div
        [ class [TagFormCss] ]
        [
          div
            [ id [TagFormTextInput] ]
            [ input
              [ placeholder "Title"
              , value tagForm.title
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
              , value tagForm.description
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


{-------------- Tag Html functions --------------}

tagShareModeHtml : Tag -> List Permission -> Bool -> Html Msg
tagShareModeHtml tag permissions formActive =
  let
    tagCss = [TagCss]
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
        (tagHtmlContents tag)
      ]

tagHtml : Tag -> List Permission -> UserId -> TagId-> Bool -> String -> String -> Html Msg
tagHtml tag permissions currentUserId lastClickedTag formActive deleteButton editTagButton =
  let
    levels =
      List.map (\perm -> perm.level)
      <| List.filter (\element -> List.member element.groupId tag.authorizedGroups) permissions
    tagCss = [TagCss]
    selectedCss =
      case (tag.id == lastClickedTag) of
        True -> tagCss ++ [SelectedTag]
        False -> tagCss
    selectedAndAltCss =
      case formActive of
        True -> selectedCss ++ [AltTag]
        False -> selectedCss
    deleteHtml =
      [ p [class [TagOptionsCss], onClick (DeleteTag tag.id)]
        [ img
          [src deleteButton]
          []
        ]
      ]
    editHtml =
      [ p [class [TagOptionsCss], onClick (EditTag tag), style [("left", "2vw")]]
        [ img
          [src editTagButton]
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
        (tagHtmlContents tag)
      ] ++ deleteHtml ++ editHtml )


{-------------- Helper functions --------------}

tagHtmlContents : Tag -> List (Html Msg)
tagHtmlContents tag =
  [ p []
    [text tag.title]
  , p []
    [text tag.category]
  , p []
    [text tag.description]
  , p []
    [text ("- " ++ tag.author.firstName ++ " " ++ tag.author.lastName)]
  ]

playerDataToHtml : (PlayerId, String, String, String) -> List PlayerId -> Html Msg
playerDataToHtml (id, ign, champName, champImage) playersInvolved
  = checkbox (AddPlayers id) champName champImage <| List.member id playersInvolved

checkbox : msg -> String -> String -> Bool -> Html msg
checkbox msg champName champImage isChecked =
  div
    [ class [CheckboxItem] ]
    [ input
        [ type_ "checkbox"
        , onClick msg
        , id champName
        , checked isChecked
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
