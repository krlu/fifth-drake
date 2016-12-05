module TagScroller.Internal.Populate exposing (..)

import Http
import Json.Decode exposing (..)
import TagScroller.Types exposing (Msg(..), Tag, TagCategory(..))
import Types exposing (WindowLocation)

tagUrl : WindowLocation -> String
tagUrl loc =
  "http://" ++ loc.host ++ "/game/" ++ loc.gameId ++ "/tags"

getTags : WindowLocation -> Http.Request (List Tag)
getTags loc = Http.get (tagUrl loc) (list tag)

populate : WindowLocation -> Cmd Msg
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
