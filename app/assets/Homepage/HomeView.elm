module HomeView exposing (view)

import DashboardCss exposing (CssClass(Dashboard))
import HomeCss exposing (CssClass(..), namespace)
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
    [ class [Home]
    ]
    [ input
      [ placeholder "Search Games"
      , onInput SearchGame
      , class [ListItem]
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
  [ class [ListItem] ]
  [ a
    [ href <| ("/game/"++ metadata.gameKey)
    ]
    [ text <| (monthToString <| month date) ++ " " ++ (toString <| day date) ++ " " ++ (toString <| year date)
    , text <| " " ++ metadata.redTeamName
    , text <| " " ++ metadata.blueTeamName
    ]
  , a [ href metadata.vodURL, class [VodItem] ] [text "Video Link"]
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
