module SettingsView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (placeholder, src)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (keyCode, on, onClick, onInput)
import Json.Decode as Json
import SettingsCss exposing (CssClass(..), namespace)
import SettingsTypes exposing (..)

{id, class, classList} = withNamespace namespace


-- View for this page is dependent on the permission levels of the user
-- In particular, only admins and owners can add and remove users
-- and owners cannot be deleted by anyone other than themselves
-- owners can also delete the entire group

view : Model -> Html Msg
view model =
  let
    (groupHtml, searchHtml) =
      case model.group of
        Just group ->
          case (model.permissions, model.currentUser) of
            (Just permissions, Just currentUser) ->
              ( viewUserGroup group model.removeUserIcon permissions currentUser
              , getSearchHtml (getPermissionLevelOfUser currentUser permissions) model.addUserIcon
              )
            _ ->
              (div [] [text <| Debug.log "PERMISSIONS OR CURRENT USER MISSING!!" "N/A"], [])
        Nothing ->
          ( div
            [ onClick SendCreateGroupRequest
            , class [CreateButton]
            ]
            [text "New"]
          , []
          )
  in
    div [ class [Settings] ]
      [ div [ class [GroupCss] ]
        ([ div [ class [GroupTitle] ]
          [ text "My Group"
          ]
         ] ++ searchHtml ++ [ groupHtml ]
        )
      ]

getSearchHtml : PermissionLevel -> Icon -> List (Html Msg)
getSearchHtml level addUserIcon =
  case level of
    "member" -> []
    _ ->
      [ input
        [ placeholder "Add user"
        , onInput UpdateSearchForm
        , class [Searchbar]
        , onEnter SendGetUserRequest
        ]
        []
      , button
        [ onClick SendGetUserRequest
        , class [AddButton]
        ]
        [ img [src addUserIcon] [] ]
      ]

viewUserGroup : UserGroup -> Icon -> List Permission -> User -> Html Msg
viewUserGroup group removeIcon permissions currentUser=
  let
     membersHtml =
      List.map (viewUserInGroup removeIcon permissions currentUser) group.members
  in
    div [class [UsersBackgroundPane]] membersHtml

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

viewUserInGroup : Icon -> List Permission -> User -> User -> Html Msg
viewUserInGroup removeIcon permissions currentUser user =
  let
    currentLevel = getPermissionLevelOfUser currentUser permissions
    userLevel = getPermissionLevelOfUser user permissions
    deleteHtml =
      case (currentLevel, userLevel) of
        ("member", _)  -> []
        ("admin", "admin") -> []
        ("admin", "owner") -> []
        ("owner", "owner") -> []
        _ ->
          [div
            [ onClick (RemoveUser user)
            , class [DeleteButtonCss]
            ]
            [ img [src removeIcon] [] ]
          ]
  in
    div [class [GroupRow] ]
    (
    [ div [class[GroupCell]] [ text user.email ]
    , div [class[GroupCell]] [ text <| user.firstName ++ " " ++ user.lastName]
    , div [class[MemberCell]] [ text <| userLevel]
    ] ++ deleteHtml)

getPermissionLevelOfUser : User -> List Permission -> PermissionLevel
getPermissionLevelOfUser user permissions =
  let
    maybePerm = List.head <| List.filter (\perm -> perm.userId == user.id) permissions
  in
    case maybePerm of
      Just perm -> perm.level
      Nothing -> Debug.log "ERROR! PERMISSION LEVEL NOT FOUND!!" "N/A"
