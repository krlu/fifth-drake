module TagCarousel.Internal.Populate exposing (..)

import Http
import Internal.UserQuery exposing (user)
import Json.Decode exposing (map3, map8, string, field, succeed, andThen, Decoder, list, int)
import TagCarousel.Types exposing (Msg(..), Tag, TagCategory)
import Task exposing (Task)
import Navigation exposing (Location)
import Populate exposing (getGameId)
import SettingsTypes exposing (User)

tagUrl : Location -> String
tagUrl loc =
  loc.origin ++ "/game/" ++ toString (getGameId loc) ++ "/tags"

getTags : Location -> Http.Request (List Tag)
getTags loc = Http.get (tagUrl loc) (list tag)

populate : Location -> Cmd Msg
populate loc = Http.send UpdateTags <| getTags loc

tag : Decoder Tag
tag =
  map8 Tag
    (field "id" string)
    (field "title" string)
    (field "description" string)
    (field "category" tagCategory)
    (field "timestamp" int)
    (field "players" <| list string)
    (field "author" <| user)
    (field "authorizedGroups" <| list string)

tagCategory : Decoder TagCategory
tagCategory = string |> andThen (\s -> succeed s)

