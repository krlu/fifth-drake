module Navbar exposing (..)

import Html.App
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
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


view : Model -> Html Msg
view model =
  let
    clazz =
      case model.collapsed of
        Expanded -> "expanded"
        Collapsed -> "collapsed"

    links =
      [ Games, Link ]
      |> List.map (\x -> link clazz ( GoTo x ) ( pageToUrl x ) )
  in
    div
      [ class ( "navbar-left " ++ clazz ) ]
      [ div
         [ id "collapsible" ]
         [ collapsibleLink model clazz ]
      , div
         [ id "navbar-left-logo" ]
         [ link clazz ( GoTo Home ) ( pageToUrl Home ) ]
      , div
         [ id "navbar-links" ]
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


collapsibleLink : Model -> String -> Html Msg
collapsibleLink model clazz =
  let
    action = ( ChangeState << flipCollapseState ) model.collapsed
    arrow = collapseStateToIcon model.collapsed
  in
      link clazz action arrow


link : String -> Msg -> String -> Html Msg
link clazz msg txt =
    a
      [ class clazz
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