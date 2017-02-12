module TagCarousel.TagCarousel exposing (init, update, view)

import GameModel exposing (GameId, Player, PlayerId, Timestamp)
import Html exposing (Html)
import TagCarousel.Types exposing (..)
import TagCarousel.Internal.Populate as Populate
import TagCarousel.Internal.TagUtils as TagUtils
import TagCarousel.Internal.Update as Update
import TagCarousel.Internal.View as View
import Navigation exposing (Location)
import UrlParser exposing ((</>), parsePath, s)

defaultCategory : String
defaultCategory = "Objective"

init : Location -> String -> String -> (Model, Cmd Msg)
init loc addTagButton deleteTagButton =
  let
      gameId = getGameId loc
      host = loc.host
      category = defaultCategory
      tagForm : TagForm
      tagForm = TagUtils.defaultTagForm gameId host category
  in
    ( { host = loc.host
      , tagForm = tagForm
      , tags = []
      , lastClickedTime = -1
      , tagButton = addTagButton
      , deleteTagButton = deleteTagButton
      },
      Populate.populate loc
    )

update : Msg -> Model -> Timestamp -> (Maybe Timestamp, Model, Cmd Msg)
update = Update.update

view : Model -> List (PlayerId, String, String, String) -> Html Msg
view = View.view

getGameId : Location -> GameId
getGameId =
  parsePath (s "game" </> UrlParser.int)
  >> \maybe ->
    case maybe of
      Just gameId -> gameId
      Nothing -> Debug.crash "No game id found in URL"
