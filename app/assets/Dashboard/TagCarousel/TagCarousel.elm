module TagCarousel.TagCarousel exposing (init, update, view)

import GameModel exposing (GameId, Player, PlayerId, Timestamp)
import Html exposing (Html)
import SettingsTypes exposing (UserId)
import TagCarousel.Types exposing (..)
import TagCarousel.Internal.Populate as Populate
import TagCarousel.Internal.TagUtils as TagUtils
import TagCarousel.Internal.Update as Update
import TagCarousel.Internal.View as View
import Navigation exposing (Location)
import Types exposing (Permission)
import UrlParser exposing ((</>), parsePath, s)

defaultCategory : TagCategory
defaultCategory = "Objective"

init : Location -> String -> String -> (Model, Cmd Msg)
init loc addTagButton deleteTagButton =
  let
      gameId = getGameId loc
      host = loc.host
      tagForm = TagUtils.defaultTagForm gameId host defaultCategory
  in
    ( { host = loc.host
      , tagForm = tagForm
      , tags = []
      , lastClickedTime = -1
      , tagButton = addTagButton
      , deleteTagButton = deleteTagButton
      , isShareForm = False
      , filteredByAuthor = False
      , groupFilters = []
      },
      Populate.populate loc
    )

update : Msg -> Model -> Timestamp -> (Maybe Timestamp, Model, Cmd Msg)
update = Update.update

view : Model -> List Permission -> UserId -> List (PlayerId, String, String, String) -> Html Msg
view = View.view

getGameId : Location -> GameId
getGameId =
  parsePath (s "game" </> UrlParser.int)
  >> \maybe ->
    case maybe of
      Just gameId -> gameId
      Nothing -> Debug.crash "No game id found in URL"
