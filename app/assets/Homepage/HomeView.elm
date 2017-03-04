module HomeView exposing (view)

import HomeTypes exposing (..)
import Date exposing (Date, Month(..), day, fromTime, month, year)
import Html exposing (Html, a, div, text)
import Html.Attributes exposing (href, style)
import Navigation exposing (Location)

view : Model -> Html Msg
view model =
  let
    gamesHtml =
      List.map (metaDataView model.location) model.games
  in
    div
    [ style
     [ ("overflow-y", "scroll")
     , ("width", "100%")
     ]
    ] gamesHtml

metaDataView : Location -> MetaData -> Html Msg
metaDataView loc metadata =
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
