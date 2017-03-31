module TagCarousel.Internal.Share exposing (sendRequest)

import Http exposing (Request, expectString, jsonBody, request)
import Json.Encode exposing (object, string)
import String
import TagCarousel.Internal.Populate exposing (tag)
import TagCarousel.Types exposing (Host, Msg(ShareToggled, TagSaved), Tag, TagId)

url : Host -> String
url host = "http://" ++ host ++ "/shareTag"

sendRequest: TagId -> Host -> Cmd Msg
sendRequest id host = Http.send ShareToggled (createRequest id host)

createRequest: TagId -> Host ->  Request String
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
      , expect = expectString
      , timeout = Nothing
      , withCredentials = False
     }
