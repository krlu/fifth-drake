module TagForm.TagForm exposing (..)

import GameModel exposing (GameId, Player, Timestamp)
import Html exposing (Html)
import TagForm.Types exposing(..)
import TagForm.Internal.View as View
import TagForm.Internal.Update as Update
import Navigation exposing (Location)
import UrlParser exposing ((</>), parsePath, s)


getGameId : Location -> GameId
getGameId =
  parsePath (s "game" </> UrlParser.int)
  >> \maybe ->
    case maybe of
      Just gameId -> gameId
      Nothing -> Debug.crash "No game id found in URL"

init : Location -> (Model, Cmd Msg)
init loc =
  let
    tagForm: Model
    tagForm =
     { title = ""
     , description = ""
     , category = ""
     , players = ""
     , gameId = getGameId loc
     , host = loc.host
     }
  in
  (tagForm, Cmd.none)

update : Msg -> Model -> Timestamp -> List Player -> (Model, Cmd Msg)
update = Update.update

view : Model -> Html Msg
view = View.view

subscriptions : Sub Msg
subscriptions = Sub.none
