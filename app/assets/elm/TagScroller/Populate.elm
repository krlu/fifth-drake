module TagScroller.Populate exposing (..)

import Http
import Json.Decode exposing (..)
import TagScroller.Messages exposing (Msg(..))
import TagScroller.Models exposing (Tag, TagType(..))
import Task exposing (Task)

tagUrl : String
tagUrl = Http.url "http://localhost:4000/tags" []

getTags : Task Http.Error (List Tag)
getTags = Http.get (list tag) tagUrl

populate : Cmd Msg
populate = Task.perform TagFetchFailure UpdateTags getTags

tag : Decoder Tag
tag =
  object2 Tag
    ("tagType" := tagType)
    ("timestamp" := int)

tagType : Decoder TagType
tagType = customDecoder string <| \s ->
  case s of
    "TeamFight" -> Ok TeamFight
    "UserDefined" -> Ok UserDefined
    _ -> Err <| s ++ " is not a proper tag type"
