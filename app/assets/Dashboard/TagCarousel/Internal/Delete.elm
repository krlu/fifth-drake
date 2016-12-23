module TagCarousel.Internal.Delete exposing (..)

import GameModel exposing (Player)
import Http exposing (Request, expectJson, expectString, jsonBody, request)
import Json.Decode as Decoder
import Json.Encode exposing (object, string)
import Navigation exposing (Location)
import TagCarousel.Types exposing (Model, Msg(TagDeleted), Tag)

url : String -> String -> String
url host tagId= "http://" ++ host ++ "/deleteTag/" ++ tagId

sendRequest: String -> String -> Cmd Msg
sendRequest id host = Http.send TagDeleted (createRequest id host)

createRequest: String -> String -> Request String
createRequest id host =
  let
    jsonData =
        object
          [ ("id", string id)
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