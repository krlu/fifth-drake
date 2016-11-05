module TagScroller.Internal.Populate exposing (..)

import Http
import Json.Decode exposing (..)
import TagScroller.Types exposing (Msg(..), Tag, TagCategory(..))
import Task exposing (Task)

tagUrl : String
tagUrl = Http.url "http://localhost:4000/tags" []

getTags : Task Http.Error (List Tag)
getTags = Http.get (list tag) tagUrl

populate : Cmd Msg
populate = Task.perform TagFetchFailure UpdateTags getTags

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
