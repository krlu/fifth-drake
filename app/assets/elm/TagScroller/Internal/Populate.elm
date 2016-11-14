module TagScroller.Internal.Populate exposing (..)

import Http
import Json.Decode exposing (..)
import TagScroller.Types exposing (Msg(..), Tag, TagCategory(..))
import Task exposing (Task)
import Types exposing (WindowLocation)

tagUrl : WindowLocation -> String
tagUrl loc =
  Http.url ("http://" ++ loc.host ++ "/game/" ++ loc.gameId ++ "/tags") []

getTags : WindowLocation -> Task Http.Error (List Tag)
getTags loc = Http.get (list tag) <| tagUrl loc

populate : WindowLocation -> Cmd Msg
populate loc = Task.perform TagFetchFailure UpdateTags <| getTags loc

tag : Decoder Tag
tag =
  object5 Tag
    ("title" := string)
    ("description" := string)
    ("category" := tagCategory)
    ("timestamp" := int)
    ("players" := list string)

tagCategory : Decoder TagCategory
tagCategory = customDecoder string <| \s ->
  case s of
    "TeamFight" -> Ok TeamFight
    "Objective" -> Ok Objective
    _ -> Err <| s ++ " is not a proper tag type"
