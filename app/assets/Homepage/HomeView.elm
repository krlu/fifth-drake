module HomeView exposing (view)

import DashboardCss exposing (CssClass(Dashboard))
import HomeCss exposing (CssClass(Home), namespace)
import HomeTypes exposing (..)
import Date exposing (Date, Month(..), day, fromTime, month, year)
import Html exposing (Html, a, div, input, text)
import Html.Attributes exposing (href, placeholder, style)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (onInput)
import Navigation exposing (Location)
import String exposing (contains, toLower, split)

{id, class, classList} = withNamespace namespace

view : Model -> Html Msg
view model =
  let
    gamesHtml =
      List.filter (isQueriedGame model.query) model.games
      |> List.map (metadataView model.location)
  in
    div
    [ style
      [ ("width", "100%")
      , ("overflow-y", "scroll")
      ]
    ]
    [ input
      [ placeholder "Search Games"
      , onInput SearchGame
      , style
        [ ("margin-top", "50px")
        , ("margin-left", "50px")
        , ("font-size", "25px")
        ]
      ]
      []
    , div
      [
      ] gamesHtml
    ]

isQueriedGame : Query -> MetaData -> Bool
isQueriedGame query metadata =
  split " " query
  |> List.map (\q -> checkQuery q metadata)
  |> List.member False
  |> not

checkQuery : Query -> MetaData -> Bool
checkQuery query metadata =
  let
    date = fromTime metadata.gameDate
  in
    List.member True
    [ contains (toLower metadata.blueTeamName) <| toLower query
    , contains (toLower metadata.redTeamName) <| toLower query
    , contains (toLower query) <| toLower metadata.blueTeamName
    , contains (toLower query) <| toLower metadata.redTeamName
    , contains (toLower query) <| toLower (toString <| day date)
    , contains (toLower <| toString <| day date) (toLower query)
    , contains (toLower query) <| toLower (toString <| month date)
    , contains (toLower <| toString <| month date) (toLower query)
    , contains (toLower query) <| toLower (toString <| year date)
    , contains (toLower <| toString <| year date) (toLower query)
    ]

metadataView : Location -> MetaData -> Html Msg
metadataView loc metadata =
  let
    date = fromTime metadata.gameDate
  in
  div
  [ style
    [ ("margin", "50px")
    , ("font-size", "20px")
    ]
  ]
  [ a
    [ href <| ("/game/"++ metadata.gameKey)
    ]
    [ text <| (monthToString <| month date) ++ " " ++ (toString <| day date) ++ " " ++ (toString <| year date)
    , text <| " " ++ metadata.redTeamName
    , text <| " " ++ metadata.blueTeamName
    ]
  ]

monthToString : Month -> String
monthToString month =
  case month of
     Jan -> "Jan"
     Feb -> "Feb"
     Mar -> "Mar"
     Apr -> "Apr"
     May -> "May"
     Jun -> "Jun"
     Jul -> "Jul"
     Aug -> "Aug"
     Sep -> "Sep"
     Oct -> "Oct"
     Nov -> "Nov"
     Dec -> "Dec"
