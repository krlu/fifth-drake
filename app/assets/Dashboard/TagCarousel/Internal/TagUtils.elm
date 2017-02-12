module TagCarousel.Internal.TagUtils exposing (..)

import GameModel exposing (GameId)
import TagCarousel.Types exposing (..)

defaultTagForm : GameId -> Host -> String -> TagForm
defaultTagForm gameId host category =
  { title = ""
  , description = ""
  , category = category
  , selectedIds = []
  , gameId = gameId
  , host = host
  , active = False
  }