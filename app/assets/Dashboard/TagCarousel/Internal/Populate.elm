module TagCarousel.Internal.Populate exposing (..)

import Http
import Json.Decode exposing (..)
import TagCarousel.Types exposing (Msg(..), Tag, TagCategory(..))
import Task exposing (Task)
import Navigation exposing (Location)
import Populate exposing (getGameId)


tagUrl : Location -> String
tagUrl loc =
    loc.origin ++ "/game/" ++ toString (getGameId loc) ++ "/tags"


getTags : Location -> Http.Request (List Tag)
getTags loc =
    Http.get (tagUrl loc) (list tag)


populate : Location -> Cmd Msg
populate loc =
    Http.send UpdateTags <| getTags loc


tag : Decoder Tag
tag =
    map6 Tag
        (field "id" string)
        (field "title" string)
        (field "description" string)
        (field "category" tagCategory)
        (field "timestamp" int)
        (field "players" <| list string)


tagCategory : Decoder TagCategory
tagCategory =
    string
        |> andThen
            (\s ->
                case s of
                    "TeamFight" ->
                        succeed TeamFight

                    "Objective" ->
                        succeed Objective

                    _ ->
                        fail <| s ++ " is not a proper tag type"
            )
