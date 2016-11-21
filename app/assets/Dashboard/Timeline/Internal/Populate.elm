module Timeline.Internal.Populate exposing (..)

import Dict
import Http
import Json.Decode exposing (Decoder, list, array, object1, object3, object5, (:=), int, float, string)
import Maybe exposing (withDefault)
import Timeline.Types exposing (GameLength, Msg(..))
import Task exposing (Task)
import Types exposing (WindowLocation)

url : WindowLocation -> String
url loc =
  Http.url ("http://" ++ loc.host ++ "/game/" ++ loc.gameId ++ "/gameLength") []

getGameLength : WindowLocation -> Task Http.Error GameLength
getGameLength loc = Http.get gameLength <| url loc

populate : WindowLocation -> Cmd Msg
populate loc = Task.perform GameLengthFetchFailure SetTimelineLength <| getGameLength loc

gameLength : Decoder GameLength
gameLength = ("gameLength" := int)

