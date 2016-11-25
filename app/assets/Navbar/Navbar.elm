module Navbar exposing (..)

import Html.App
import Html exposing (..)
import Html.Attributes exposing (href, src)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (..)
import NavbarCss exposing (CssClass, namespace)
import String exposing (toLower)

-- MODEL

type Page
  = Home
  | Games
  | Settings
  | Problem

type alias UserID = String

type alias Icon = String

type alias Model =
  { active : Page
  , user : Maybe UserID
  -- Icons
  , homeIcon : Icon
  , gamesIcon : Icon
  , settingsIcon : Icon
  , problemIcon : Icon
  }

type alias Flags =
  { homeIcon : Icon
  , gamesIcon : Icon
  , settingsIcon : Icon
  , problemIcon : Icon
  }

init : Flags -> ( Model, Cmd Msg )
init flags =
  ( { active = Home
    , user = Nothing

    , homeIcon = flags.homeIcon
    , gamesIcon = flags.gamesIcon
    , settingsIcon = flags.settingsIcon
    , problemIcon = flags.problemIcon
    }
  , Cmd.none
  )

pageToIcon : Model -> Page -> Icon
pageToIcon model page =
  case page of
    Home -> model.homeIcon
    Games -> model.gamesIcon
    Settings -> model.settingsIcon
    Problem -> model.problemIcon

pageUrl : Page -> String
pageUrl page =
  case page of
    Home -> "/"
    Games -> "/game"
    Settings -> "/setting"
    Problem -> "/problem"

-- MESSAGES

type Msg = Unit

-- VIEW

{id, class, classList} = withNamespace namespace

view : Model -> Html Msg
view model =
  let
    link : Page -> Html Msg
    link page =
        a
          [ href <| pageUrl page
          ]
          [ img
            [src <| pageToIcon model page ]
            []
          ]

    links =
      [ Games, Settings, Problem ]
      |> List.map link
  in
    div
      [ class [NavbarCss.NavbarLeft] ]
      [ a
        [ id NavbarCss.NavbarLeftLogo
        , href <| pageUrl Home
        ]
        [ img
          [src <| pageToIcon model Home]
          []
        ]
      , div
        [ id NavbarCss.NavbarLinks ]
        links
      ]

-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = (model, Cmd.none)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- MAIN

main : Program Flags
main =
  Html.App.programWithFlags
  { init = init
  , update = update
  , view = view
  , subscriptions = subscriptions
  }