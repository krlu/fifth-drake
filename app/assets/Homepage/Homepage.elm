module Homepage exposing (..)

import Array exposing (Array, set)
import Dict
import Date exposing (Date)
import GameModel exposing (GameLength)
import Html exposing (Html, div, text)
import Http
import Json.Decode exposing (..)
import Navigation exposing (Location)
import Set exposing (Set)

type Msg
  = SearchGame
  | LocationUpdate Location
  | GetGames (Result Http.Error (List MetaData))

type alias GameKey = String

type alias Flags =
  {

  }

type alias MetaData =
  { gameLength : GameLength
  , blueTeamName : String
  , redTeamName : String
  , gameDate : Int
  , voURL: String
  , gameKey : GameKey
  }

type alias Model =
  { games : List MetaData
  , selectedGames : Set GameKey
  }

init : Flags -> Location -> (Model, Cmd Msg)
init flags location =
  ( { games = []
    , selectedGames = Set.empty
    }
  , populate location
  )

view : Model -> Html Msg
view model =
  let
    games = Debug.log "" model.games
  in
    div [] [ text "hello world"]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    LocationUpdate loc -> (model, Cmd.none)
    SearchGame -> (model, Cmd.none)
    GetGames (Ok games) ->({ model | games = games}, Cmd.none)
    GetGames (Err err) -> (Debug.log "Games failed to fetch!" model, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

populate : Location -> Cmd Msg
populate loc = Http.send GetGames <| getGames loc

getGames : Location -> Http.Request (List MetaData)
getGames loc = Http.get (gamesUrl loc) (list metadata)

gamesUrl : Location -> String
gamesUrl loc =  loc.origin ++ "/games"

metadata : Decoder MetaData
metadata =
  map6 MetaData
    ( field "gameLength" gameLength )
    ( field "blueTeamName" string )
    ( field "redTeamName" string )
    ( field "gameDate" int )
    ( field "vodURL" string )
    ( field "gameKey" string)

gameLength : Decoder GameLength
gameLength = int

main : Program Flags Model Msg
main =
  Navigation.programWithFlags
    LocationUpdate
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
