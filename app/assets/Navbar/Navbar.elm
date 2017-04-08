module Navbar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href, src)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (..)
import NavbarCss exposing (CssClass(..), namespace)
import Navigation
import String exposing (toLower)
import Navigation exposing (Location)

-- MODEL

type Page
  = Home
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
  , toolTip : Maybe Page
  }

type alias Flags =
  { homeIcon : Icon
  , gamesIcon : Icon
  , settingsIcon : Icon
  , problemIcon : Icon
  , logoutIcon : Icon
  }

init : Flags -> Location ->( Model, Cmd Msg )
init flags loc =
  let
    activePage =
      case loc.pathname of
        "/home" -> Home
        "/settings" -> Settings
        "/problem" -> Problem
        "/logout" -> Logout
        _ -> Landing
  in
    ( { active = activePage
      , user = Nothing
      , homeIcon = flags.homeIcon
      , gamesIcon = flags.gamesIcon
      , settingsIcon = flags.settingsIcon
      , problemIcon = flags.problemIcon
      , logoutIcon = flags.logoutIcon
      , toolTip = Nothing
      }
    , Cmd.none
    )

pageToIcon : Model -> Page -> Icon
pageToIcon model page =
  case page of
    Home -> model.homeIcon
    Landing -> "" -- LOGO FAVICON GOES HERE!!!!!!
    Settings -> model.settingsIcon
    Problem -> model.problemIcon
    Logout -> model.logoutIcon


pageUrl : Page -> String
pageUrl page =
  case page of
    Home -> "/home"
    Settings -> "/settings"
    Problem -> "/problem"
    Logout -> "/logout"
    Landing -> "/"


pageToText : Page -> String
pageToText page =
  case page of
    Home -> "Home Page"
    Settings -> "Settings"
    Problem -> "Bug Report"
    Logout -> "Logout"
    Landing -> "Landing Page"

-- MESSAGES

type Msg
  = LocationUpdate Location
  | ShowToolTip Page
  | HideToolTip


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
      let
        toolTipText = text <| pageToText page
        toolTipHtml =
          case model.toolTip of
            Just tipPage ->
              case tipPage == page of
                True -> [div [class [ToolTip]] [toolTipText]]
                False -> []
            Nothing -> []
      in
        a
          ([ href <| pageUrl page
           , onMouseOver (ShowToolTip page)
           , onMouseOut (HideToolTip)
           ] ++ selected page)
          ([ img
            [src <| pageToIcon model page ]
            []
          ] ++ toolTipHtml)

    links =
      [ Home, Settings, Problem, Logout]
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
update msg model =
  case msg of
    LocationUpdate loc -> (model, Cmd.none)
    ShowToolTip page -> ({model | toolTip = Just page}, Cmd.none)
    HideToolTip -> ({model | toolTip = Nothing}, Cmd.none)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- MAIN

main : Program Flags Model Msg
main =
  Navigation.programWithFlags
    LocationUpdate
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }
