module TagForm.Internal.Save exposing (..)

import Char exposing (isDigit)
import GameModel exposing (Player, Timestamp)
import Http exposing (Request, expectJson, jsonBody, multipartBody, request, stringPart)
import Json.Decode as Decoder
import Json.Encode exposing (Value, int, list, object, string)
import Regex exposing (HowMany(All), regex, replace)
import String as String
import TagForm.Internal.SaveTypes exposing (Msg(TagSaved))
import TagForm.Types exposing(Model)

url : String -> String
url host = "http://" ++ host ++ "/saveTag"

sendRequest: Model -> Timestamp -> List Player -> Cmd Msg
sendRequest model ts players = Http.send TagSaved (createRequest model ts)

createRequest: Model -> Timestamp -> Request String
createRequest model ts =
  let
    jsonData =
        object
          [ ("gameKey", string (toString model.gameId))
          , ("title", string model.title)
          , ("description", string model.description)
          , ("category", string model.category)
          , ("timestamp", int ts)
          , ("playerIgns", list <| List.map string
                                <| String.split ","
                                <| String.filter ((/=) ' ') model.players)
          ]
    body = jsonBody jsonData
  in
    request
     {  method = "PUT"
      , headers = []
      , url = url model.host
      , body = body
      , expect = expectJson Decoder.string
      , timeout = Nothing
      , withCredentials = False
     }
