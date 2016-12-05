module TagScroller.Internal.Populate exposing (..)

import GameModel exposing (GameId)
import Http
import Json.Decode exposing (..)
import Navigation exposing (Location)
import TagScroller.Types exposing (Msg(..), Tag, TagCategory(..))

tagUrl : String -> GameId -> String
tagUrl host gameId =
  "http://" ++ host ++ "/game/" ++ toString gameId ++ "/tags"

getTags : String -> GameId -> Http.Request (List Tag)
getTags host gameId = Http.get (tagUrl host gameId) (list tag)

populate : String -> GameId -> Cmd Msg
populate host gameId = Http.send UpdateTags <| getTags host gameId

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
