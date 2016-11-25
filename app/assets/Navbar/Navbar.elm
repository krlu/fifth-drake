module Navbar exposing (..)

import Html.App
import Html exposing (..)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (..)
import NavbarCss exposing (CssClass, namespace)
import String exposing (toLower)

-- MODEL

type Page
  = Home
  | LogIn
  | Profile
  | Games
  | Link

type alias UserID = String

type alias Icon = String

type alias Model =
  { active : Page
  , user : Maybe UserID
  }

init : ( Model, Cmd Msg )
init =
  ( { active = Home
    , user = Nothing
    }, Cmd.none )

pageToUrl : Page -> String
pageToUrl page =
  case page of
    Home -> "Climb.gg"
    LogIn -> "Log In"
    Profile -> "Profile"
    Games -> "Games"
    Link -> "Link"

-- MESSAGES

type Msg
  = GoTo Page
  | LoggedIn UserID
  | LoggedOut

-- VIEW

{id, class, classList} = withNamespace namespace

view : Model -> Html Msg
view model =
  let
    links =
      [ Games, Link ]
      |> List.map (\x -> link ( GoTo x ) ( pageToUrl x ) )
  in
    div
      [ class [NavbarCss.NavbarLeft] ]
      [ div
         [ class [ NavbarCss.Collapsible ] ]
         []
      , div
         [ id NavbarCss.NavbarLeftLogo ]
         [ link ( GoTo Home ) ( pageToUrl Home ) ]
      , div
         [ id NavbarCss.NavbarLinks ]
         links
      ]

link : Msg -> String -> Html Msg
link msg txt =
    a
      [ onClick msg
      ]
      [ span
          []
          [ text txt ]
      ]

-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    LoggedIn userId -> ( { model | user = Just userId }, Cmd.none )
    LoggedOut -> ( { model | user = Nothing }, Cmd.none )
    GoTo page -> ( { model | active = page }, Cmd.none )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- MAIN

main : Program Never
main =
  Html.App.program
  { init = init
  , update = update
  , view = view
  , subscriptions = subscriptions
  }