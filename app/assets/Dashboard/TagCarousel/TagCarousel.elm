module TagCarousel.TagCarousel exposing (init, update, view)

import GameModel exposing (GameId, Player, PlayerId, Timestamp)
import Html exposing (Html)
import TagCarousel.Types exposing (..)
import TagCarousel.Internal.Populate as Populate
import TagCarousel.Internal.Update as Update
import TagCarousel.Internal.View as View
import Navigation exposing (Location)
import UrlParser exposing ((</>), parsePath, s)

init : Location -> (Model, Cmd Msg)
init loc =
  let
      tagForm : TagForm
      tagForm =
       { title = ""
       , description = ""
       , category = ""
       , selectedIds = []
       , gameId = getGameId loc
       , host = loc.host
       , active = False
       }
  in
    ({host = loc.host, tagForm = tagForm, tags = [], lastClickedTagId = "" }, Populate.populate loc)

update : Msg -> Model -> Timestamp -> (Maybe Timestamp, Model, Cmd Msg)
update = Update.update

view : Model -> List (PlayerId, String) -> Html Msg
view = View.view

getGameId : Location -> GameId
getGameId =
  parsePath (s "game" </> UrlParser.int)
  >> \maybe ->
    case maybe of
      Just gameId -> gameId
      Nothing -> Debug.crash "No game id found in URL"
