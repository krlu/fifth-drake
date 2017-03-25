module SettingsView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (placeholder, src)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (keyCode, on, onClick, onInput)
import Json.Decode as Json
import SettingsCss exposing (CssClass(..), namespace)
import SettingsTypes exposing (..)

{id, class, classList} = withNamespace namespace

view : Model -> Html Msg
view model =
  let
    groupHtml =
      case model.group of
        Just group -> viewUserGroup group model.addUserIcon model.removeUserIcon
        Nothing -> div [] [text "Create New Group"]
  in
    div [ class [Settings] ]
      [ div [ class [GroupCss] ]
        [ div [ class [GroupTitle] ]
          [ text "My Group"
          ]
        , groupHtml
        ]
      ]

viewUserGroup : UserGroup -> Icon -> Icon -> Html Msg
viewUserGroup group addIcon removeIcon =
  let
     membersHtml = List.map (viewUserInGroup removeIcon) group.members
  in
    div [class [UsersBackgroundPane]]
    (membersHtml ++
    [ input
      [ placeholder "Add user"
      , onInput UpdateSearchForm
      , class [Searchbar]
      , onEnter SendGetUserRequest
      ]
      []
    , button
      [ onClick SendGetUserRequest
      , class [Button]
      ]
      [ img [src addIcon] [] ]
    ])

onEnter : Msg -> Attribute Msg
onEnter msg =
  let
    isEnter code =
      if code == 13 then
        Json.succeed msg
      else
        Json.fail "not ENTER"
  in
    on "keydown" (Json.andThen isEnter keyCode)

viewUserInGroup : Icon -> User -> Html Msg
viewUserInGroup removeIcon user =
  div [class [GroupRow] ]
  [ div [class[GroupCell]] [ text user.email ]
  , div [class[GroupCell]] [ text <| user.firstName ++ " " ++ user.lastName]
  , div
    [ onClick (RemoveUser user)
    , class [DeleteButtonCss]
    ]
    [ img [src removeIcon] [] ]
  ]
