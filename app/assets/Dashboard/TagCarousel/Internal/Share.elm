module TagCarousel.Internal.Share exposing (sendRequest)

import Http exposing (Request, expectJson, jsonBody, request)
import Json.Decode exposing (Decoder, bool, field, map3)
import Json.Encode exposing (object, string)
import String
import TagCarousel.Internal.Populate exposing (tag)
import TagCarousel.Types exposing (Host, Msg(ShareToggled, TagSaved), ShareData, Tag, TagId)

url : Host -> String
url host = "http://" ++ host ++ "/shareTag"

sendRequest: TagId -> Host -> Cmd Msg
sendRequest id host = Http.send ShareToggled (createRequest id host)

createRequest: TagId -> Host ->  Request ShareData
createRequest id host =
  let
    jsonData =
        object
          [ ("tagId", string id)
          ]
    body = jsonBody jsonData
  in
    request
     {  method = "PUT"
      , headers = []
      , url = Debug.log "" (url host)
      , body = body
      , expect = expectJson shareData
      , timeout = Nothing
      , withCredentials = False
     }

shareData : Decoder ShareData
shareData =
  map3 ShareData
    (field "tagId" Json.Decode.string)
    (field "groupId" Json.Decode.string)
    (field "nowShared" bool)
