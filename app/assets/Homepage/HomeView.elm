module HomeView exposing (view)

import DashboardCss exposing (CssClass(Dashboard))
import HomeCss exposing (CssClass(..), namespace)
import HomeTypes exposing (..)
import Date exposing (Date, Month(..), day, fromTime, month, year)
import Html exposing (Html, a, div, input, table, td, text, tr)
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
      , class [Searchbar]
      ]
      []
    , table []
      ( [header] ++ gamesHtml )
    ]

header : Html Msg
header =
  tr [ class [TableHeader] ]
  [ td [ ]
    [ text <| "Date"
    ]
  , td [] [ text "Blue Team" ]
  , td [] [ text "Red Team" ]
  , td [] [ text "Game Number" ]
  , td [] [ text "League" ]
  , td [] [ text "Year" ]
  , td [] [ text "Split" ]
  , td [] [ text "Phase"]
  , td [] [ text "Video" ]
  , td [] [ text "DashBoard"]
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
    date = fromTime metadata.timeFrame.gameDate
  in
    List.member True
    [ contains (toLower query) <| toLower metadata.blueTeamName
    , contains (toLower query) <| toLower metadata.redTeamName
    , contains (toLower query) <| toLower (toString <| day date)
    , contains (toLower query) <| toLower (toString <| month date)
    , contains (toLower query) <| toLower (toString <| year date)
    , contains (toLower query) <| toLower metadata.tournament.split
    , contains (toLower query) <| toLower metadata.tournament.league
    , contains (toLower query) <| toLower metadata.tournament.phase
    ]

metadataView : Location -> MetaData -> Html Msg
metadataView loc metadata =
  let
    date = fromTime metadata.timeFrame.gameDate
  in
    tr [ class [TableBody] ]
    [ td [ ]
      [ text <| (monthToString <| month date) ++ " " ++ (toString <| day date) ++ " " ++ (toString <| year date)
      ]
    , td [] [ text <| " " ++ metadata.blueTeamName ]
    , td [] [ text <| " " ++ metadata.redTeamName ]
    , td [] [ text <| "Game " ++ (toString metadata.gameNumber) ]
    , td [] [ text metadata.tournament.league ]
    , td [] [ text <| toString metadata.tournament.year ]
    , td [] [ text metadata.tournament.split ]
    , td [] [ text metadata.tournament.phase ]
    , td [] [a [ href metadata.vodURL ] [ text "VOD" ]]
    , td []
      [ a
        [ href <| ("/game/"++ metadata.gameKey)
        ]
        [ text <| "DB"
        ]
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
