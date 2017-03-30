module Navbar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href, src)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (..)
import NavbarCss exposing (CssClass(..), namespace)
import String exposing (toLower)

-- MODEL

type Page
  = Home
  | Games
  | Settings
  | Problem
  | Logout
  | Landing

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
  , logoutIcon : Icon
  }

type alias Flags =
  { homeIcon : Icon
  , gamesIcon : Icon
  , settingsIcon : Icon
  , problemIcon : Icon
  , logoutIcon : Icon
  }

init : Flags -> ( Model, Cmd Msg )
init flags =
  ( { active = Games
    , user = Nothing

    , homeIcon = flags.homeIcon
    , gamesIcon = flags.gamesIcon
    , settingsIcon = flags.settingsIcon
    , problemIcon = flags.problemIcon
    , logoutIcon = flags.logoutIcon
    }
  , Cmd.none
  )

pageToIcon : Model -> Page -> Icon
pageToIcon model page =
  case page of
    Home -> model.homeIcon
    Landing -> "" -- LOGO FAVICON GOES HERE!!!!!!
    Games -> model.gamesIcon
    Settings -> model.settingsIcon
    Problem -> model.problemIcon
    Logout -> model.logoutIcon


pageUrl : Page -> String
pageUrl page =
  case page of
    Home -> "/home"
    Games -> "/game"
    Settings -> "/settings"
    Problem -> "/problem"
    Logout -> "/logout"
    Landing -> "/"

-- MESSAGES

type Msg = Unit

-- VIEW

{id, class, classList} = withNamespace namespace

view : Model -> Html Msg
view model =
  let
    selected : Page -> List (Html.Attribute a)
    selected page =
      if model.active == page
      then [ class [Selected] ]
      else []

    link : Page -> Html Msg
    link page =
        a
          ([ href <| pageUrl page
           ] ++ selected page)
          [ img
            [src <| pageToIcon model page ]
            []
          ]

    links =
      [ Home, Games, Settings, Problem, Logout]
      |> List.map link
  in
    div
      [ class [NavbarCss.NavbarLeft] ]
      [ div
        [ id NavbarCss.NavbarLeftLogo
        ]
        [ a
          [ href <| pageUrl Landing ]
          [ text "C" -- LOGO FAVICON GOES HERE!!!!!!
          ]
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

main : Program Flags Model Msg
main =
  Html.programWithFlags
  { init = init
  , update = update
  , view = view
  , subscriptions = subscriptions
  }
