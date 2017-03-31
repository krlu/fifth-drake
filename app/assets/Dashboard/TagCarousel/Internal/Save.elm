module TagCarousel.Internal.Save exposing (..)

import GameModel exposing (Player, Timestamp)
import Http exposing (Request, expectJson, jsonBody, request)
import Json.Decode as Decoder
import Json.Encode exposing (Value, bool, int, list, object, string)
import String
import TagCarousel.Internal.Populate exposing (tag)
import TagCarousel.Types exposing (Msg(TagSaved), Tag, TagForm)

url : String -> String
url host = "http://" ++ host ++ "/saveTag"

sendRequest: TagForm -> Timestamp -> Cmd Msg
sendRequest model ts = Http.send TagSaved (createRequest model ts)

createRequest: TagForm -> Timestamp -> Request (List Tag)
createRequest model ts =
  let
    jsonData =
        object
          [ ("gameKey", string (toString model.gameId))
          , ("title", string model.title)
          , ("description", string model.description)
          , ("category", string model.category)
          , ("timestamp", int ts)
          , ("relevantPlayerIds", list <| List.map string model.selectedIds)
          , ("shareWithGroup", bool model.toShare)
          ]
    body = jsonBody jsonData
  in
    request
     {  method = "PUT"
      , headers = []
      , url = (url model.host) ++ "/" ++ (toString model.gameId)
      , body = body
      , expect = expectJson (Decoder.list tag)
      , timeout = Nothing
      , withCredentials = False
     }
