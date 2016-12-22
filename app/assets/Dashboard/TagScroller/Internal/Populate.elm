module TagScroller.Internal.Populate exposing (..)

import GameModel exposing (GameId)
import Http
import Json.Decode exposing (..)
import Navigation exposing (Location)
import Populate exposing (getGameId)
import TagScroller.Types exposing (Msg(..), Tag, TagCategory(..))

tagUrl : Location -> String
tagUrl loc =
  loc.origin ++ "/game/" ++ toString (getGameId loc) ++ "/tags"

getTags : Location -> Http.Request (List Tag)
getTags loc = Http.get (tagUrl loc) (list tag)

populate : Location -> Cmd Msg
populate loc = Http.send UpdateTags <| getTags loc

tag : Decoder Tag
tag =
  map5 Tag
    (field "title" string)
    (field "description" string)
    (field "category" tagCategory)
    (field "timestamp" int)
    (field "players" <| list string)

tagCategory : Decoder TagCategory
tagCategory =
  string
  |> andThen (\s ->
    case s of
      "TeamFight" -> succeed TeamFight
      "Objective" -> succeed Objective
      _ -> fail <| s ++ " is not a proper tag type")