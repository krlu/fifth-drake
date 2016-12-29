module TagCarousel.Internal.Delete exposing (..)

import GameModel exposing (Player)
import Http exposing (Request, expectJson, expectString, jsonBody, request)
import Json.Decode as Decoder
import Json.Encode exposing (int, object, string)
import Navigation exposing (Location)
import TagCarousel.Types exposing (Model, Msg(TagDeleted), Tag, TagId)

url : String -> TagId -> String
url host tagId= "http://" ++ host ++ "/deleteTag/" ++ (toString tagId)

sendRequest: TagId -> String -> Cmd Msg
sendRequest id host = Http.send TagDeleted (createRequest id host)

createRequest: TagId -> String -> Request String
createRequest id host =
  let
    jsonData =
        object
          [ ("id", int id)
          ]
    body = jsonBody jsonData
  in
    request
     {  method = "DELETE"
      , headers = []
      , url = url host id
      , body = body
      , expect = expectString
      , timeout = Nothing
      , withCredentials = False
     }
