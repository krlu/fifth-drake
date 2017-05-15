module TagCarousel.Internal.View exposing (view)

import Css exposing (backgroundColor)
import GameModel exposing (Player, PlayerId, Timestamp)
import Html exposing (..)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (onClick, onMouseLeave, onMouseOver)
import String
import TagCarousel.Css exposing (CssClass(..), namespace)
import TagCarousel.Types exposing (Model, Msg(..), Tag, TagFilter(..), TagForm, TagId)
import Html.Attributes exposing (checked, defaultValue, for, href, placeholder, rel, src, style, type_, value)
import Html.Events exposing (onClick, onInput)
import SettingsTypes exposing (GroupId, UserId)
import Types exposing (Permission)

{id, class, classList} = withNamespace namespace

view : Model -> List Permission -> UserId -> List (PlayerId, String, String, String) -> Html Msg
view model permissions currentUserId players =
  let

  {------------ Apply filters to list of tags -------------}

    (filteredTags, autoTagFilterCss, groupTagFilterCss, myTagFilterCss, allTagsFilterCss) =
      case model.tagFilter of
        AllTags ->
          (model.tags, UnselectedFilter, UnselectedFilter, UnselectedFilter, SelectedFilter)
        AutoTags ->
          (List.filter (\tag -> isAutoTag tag) model.tags,
            SelectedFilter, UnselectedFilter, UnselectedFilter, UnselectedFilter)
        GroupTags groupId -> (List.filter (tagInAllGroups [groupId]) model.tags,
           UnselectedFilter, SelectedFilter, UnselectedFilter, UnselectedFilter)
        MyTags ->
          (List.filter (\tag -> tag.author.id == currentUserId) model.tags,
          UnselectedFilter, UnselectedFilter, SelectedFilter, UnselectedFilter)
    tagsShare = List.sortBy .timestamp model.tags
                |> List.filter (\tag -> tag.author.id == currentUserId)
                |> List.map (\tag -> tagShareModeHtml tag permissions model.tagForm.active)

    {----------------- Generate HTML/CSS elements for Tag Carousel -------------------}

    tags = List.sortBy .timestamp (filteredTags)
           |> List.map (\tag ->
              tagHtml tag permissions currentUserId model.lastClickedTag
                model.tagForm.active model.deleteTagButton model.editTagButton)
    tagFormView = tagFormHtml model players
    carouselCss =
      case model.tagForm.active of
        True -> [TagCarousel, MinimizedCarousel]
        False -> [TagCarousel]
    allTagsFilterHtml = buildFilterHtml ShowAllTags "All Tags" allTagsFilterCss
    autoTagsFilterHtml = buildFilterHtml ShowAutoTags "Auto Tags" autoTagFilterCss
    myTagFilterHtml = buildFilterHtml ShowMyTags "My Tags" myTagFilterCss
    groupFilterHtml =
      List.map (\perm ->
        buildFilterHtml (ShowTagsForGroup perm.groupId) "Group Tags" groupTagFilterCss) permissions
    (shareFormButtonLabel, tagsHtml, filterHtml) =
      case model.isShareForm of
       True ->
        ("Done", tagsShare, [])
       False -> ("Share Tags", tags, [allTagsFilterHtml, autoTagsFilterHtml, myTagFilterHtml] ++ groupFilterHtml)
    carouselControlsHtml =
      case (List.length permissions) == 0 of
        False ->
          ([ div
           [class [ShareTagCss, CarouselControlCss]
           , onClick ToggleCarouselForm]
           [ text shareFormButtonLabel
           ]
          ] ++ filterHtml)
        True -> filterHtml
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

tagInAllGroups : List GroupId -> TagCarousel.Types.Tag -> Bool
tagInAllGroups groupIds tag =
  not
  <| List.member False
  <| List.map (\id -> List.member id tag.authorizedGroups) groupIds

buildFilterHtml : Msg -> String -> CssClass -> Html Msg
buildFilterHtml action label  filterCss =
  div
  [class [FilterTagCss, filterCss, CarouselControlCss]
  , onClick action
  ]
  [ text label
  ]


{-------------- TagForm Html functions --------------}

tagFormHtml : Model -> List (PlayerId, String, String, String) -> Html Msg
tagFormHtml model players =
  let
    tagForm = model.tagForm
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
      case isAutoTag tag of
        True -> []
        False ->
          [ p [class [TagOptionsCss], onClick (DeleteTag tag.id)]
            [ img
              [src deleteButton]
              []
            ]
          ]
    editHtml =
      case isAutoTag tag of
        True -> []
        False ->
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

isAutoTag : Tag -> Bool
isAutoTag tag = String.contains "auto" tag.id

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
