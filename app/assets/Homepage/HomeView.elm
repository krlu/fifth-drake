module HomeView exposing (view)

import DashboardCss exposing (CssClass(Dashboard))
import HomeCss exposing (CssClass(..), namespace)
import HomeTypes exposing (..)
import Date exposing (Date, Month(..), day, fromTime, month, year)
import Html exposing (Html, a, button, div, img, input, table, td, text, tr)
import Html.Attributes exposing (href, placeholder, src, style)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (onClick, onInput)
import Navigation exposing (Location)
import String exposing (contains, toLower, split)

{id, class, classList} = withNamespace namespace

view : Model -> Html Msg
view model =
  let
    gamesList = List.filter (isQueriedGame model.query) model.games
                |> List.sortBy (\model -> model.timeFrame.gameDate)
    sortedList = case model.order of
                  Ascending -> gamesList
                  Descending -> List.reverse gamesList
    gamesHtml = sortedList |> List.map (metadataView model.location)
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
      ( [header model] ++ gamesHtml )
    ]

header : Model -> Html Msg
header model =
  let
    orderArrow =
      case model.order of
        Ascending -> img [ src model.downArrow ] []
        Descending -> img [ src model.upArrow ] []
  in
  tr [ class [TableHeader] ]
  [ td [onClick SwitchOrder, class [DateHeader]]
    [ text ("Date (")
    , orderArrow
    , text ")"
    ]
  , td [] [ text "League" ]
  , td [] [ text "Tournament" ]
  , td [] [ text "patch" ]
  , td [] [ text "Week" ]
  , td [] [ text "Blue Team" ]
  , td [] [ text "Red Team" ]
  , td [] [ text "Game #" ]
  , td [] [ text "Video" ]
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
    patchComponents = split "." metadata.timeFrame.patch |> List.take 2
    extractStr : Maybe String -> String
    extractStr str =
      case str of
        Just s -> s
        Nothing -> ""
    part1 = extractStr <| List.head patchComponents
    part2 = extractStr <| List.head <| List.reverse patchComponents
    patch = part1 ++ "." ++ part2
  in
    tr [ class [RowItem] ]
    [ td [ ]
      [ text <| (monthToString <| month date) ++ " " ++ (toString <| day date) ++ " " ++ (toString <| year date)
      ]
    , td [] [ text metadata.tournament.league ]
    , td [] [ text
              ( (toString metadata.tournament.year)
                ++ " " ++ metadata.tournament.split
                ++ " " ++ metadata.tournament.phase)
            ]
    , td [] [ text patch ]
    , td [] [ text <| toString metadata.timeFrame.week ]
    , td [] [ text <| metadata.blueTeamName ]
    , td [] [ text <| metadata.redTeamName ]
    , td [] [ a [ href <| ("/game/"++ metadata.gameKey)] [text <| "Game " ++ (toString metadata.gameNumber)] ]
    , td [] [ a [ href metadata.vodURL ] [ text "VOD" ]]
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
