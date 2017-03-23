module SettingsView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (placeholder, src)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (onClick, onInput)
import SettingsCss exposing (CssClass(..), namespace)
import SettingsTypes exposing (..)

{id, class, classList} = withNamespace namespace

view : Model -> Html Msg
view model =
  let
    groupHtml =
      case model.group of
        Just group -> viewUserGroup group
        Nothing -> div [] [text "Create New Group"]
  in
    div [ class [Settings] ]
      [ div [ class [GroupCss] ]
        [ div [ class [GroupTitle] ]
          [ text "My Group"
          ]
        , groupHtml
        ]
      , div [ class [Search] ]
        [ input
          [ placeholder "Search user"
          , onInput UpdateSearchForm
          , class [Searchbar]
          ]
          []
        , button
          [ onClick SendGetUserRequest
          , class [Button]
          ]
          [ img [src model.searchIcon] [] ]
        ]
      ]

viewUserGroup :  UserGroup -> Html Msg
viewUserGroup group =
  let
     membersHtml = List.map viewUserInGroup group.members
  in
    table [] membersHtml

viewUserInGroup : User -> Html Msg
viewUserInGroup user =
  tr [class [RowItem]]
    [ td [] [ text user.email ]
    , td [] [ text <| user.firstName ++ " " ++ user.lastName ]
    ]
