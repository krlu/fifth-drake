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


type CollapseState
  = Expanded
  | Collapsed


type alias Model =
  { active : Page
  , user : Maybe UserID
  , collapsed: CollapseState
  }


init : ( Model, Cmd Msg )
init =
  ( { active = Home
    , user = Nothing
    , collapsed = Expanded
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
  = ChangeState CollapseState
  | GoTo Page
  | LoggedIn UserID
  | LoggedOut


-- VIEW

{id, class, classList} = withNamespace namespace

view : Model -> Html Msg
view model =
  let
    clazz =
      case model.collapsed of
        Expanded -> NavbarCss.Expanded
        Collapsed -> NavbarCss.Collapsed

    links =
      [ Games, Link ]
      |> List.map (\x -> link clazz ( GoTo x ) ( pageToUrl x ) )
  in
    div
      [ class [NavbarCss.NavbarLeft, clazz] ]
      [ div
         [ class [ NavbarCss.Collapsible ] ]
         [ collapsibleLink model clazz ]
      , div
         [ id NavbarCss.NavbarLeftLogo ]
         [ link clazz ( GoTo Home ) ( pageToUrl Home ) ]
      , div
         [ id NavbarCss.NavbarLinks ]
         links
      ]


collapseStateToIcon : CollapseState -> Icon
collapseStateToIcon state =
  case state of
    Expanded -> "<"
    Collapsed -> ">"


flipCollapseState : CollapseState -> CollapseState
flipCollapseState state =
  case state of
    Expanded -> Collapsed
    Collapsed -> Expanded


collapsibleLink : Model -> CssClass -> Html Msg
collapsibleLink model clazz =
  let
    action = ( ChangeState << flipCollapseState ) model.collapsed
    arrow = collapseStateToIcon model.collapsed
  in
      link clazz action arrow


link : CssClass -> Msg -> String -> Html Msg
link clazz msg txt =
    a
      [ class [clazz]
      , onClick msg
      ]
      [ span
          []
          [ text txt ]
      ]

-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ChangeState b -> ( { model | collapsed = b } , Cmd.none )
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