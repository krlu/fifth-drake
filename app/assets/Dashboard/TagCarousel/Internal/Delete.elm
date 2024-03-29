module TagCarousel.Internal.Delete exposing (sendRequest)

import GameModel exposing (Player)
import Http exposing (Request, emptyBody, expectJson, expectString, jsonBody, request)
import Json.Decode as Decoder
import Json.Encode exposing (object, string)
import Navigation exposing (Location)
import TagCarousel.Types exposing (Model, Msg(TagDeleted), Tag, TagId)

url : String -> TagId -> String
url host tagId= "http://" ++ host ++ "/deleteTag/" ++ tagId

sendRequest: TagId -> String -> Cmd Msg
sendRequest id host = Http.send TagDeleted (createRequest id host)

createRequest: TagId -> String -> Request String
createRequest id host =
    request
     {  method = "DELETE"
      , headers = []
      , url = url host id
      , body = emptyBody
      , expect = expectString
      , timeout = Nothing
      , withCredentials = False
     }
