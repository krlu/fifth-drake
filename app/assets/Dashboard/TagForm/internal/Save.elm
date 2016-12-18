module TagForm.Internal.Save exposing (..)

import GameModel exposing (Player, Timestamp)
import Http exposing (Request, expectJson, jsonBody, request)
import Json.Decode as Decoder
import Json.Encode exposing (Value, int, list, object, string)
import String as String
import TagForm.Internal.SaveTypes exposing (Msg(TagSaved))
import TagForm.Types exposing(Model)

url : String -> String
url host = "http://" ++ host ++ "/saveTag"

sendRequest: Model -> Timestamp -> List Player -> Cmd Msg
sendRequest model ts players = Http.send TagSaved (createRequest model ts players)

createRequest: Model -> Timestamp -> List Player -> Request String
createRequest model ts allPlayers =
  let
    jsonData =
        object
          [ ("gameKey", string (toString model.gameId))
          , ("title", string model.title)
          , ("description", string model.description)
          , ("category", string model.category)
          , ("timestamp", int ts)
          , ("relevantPlayerIgns", list <| List.map string
                                <| String.split ","
                                <| String.filter ((/=) ' ') model.players)
          , ("allPlayerData", object <| List.map getIdAndIgn allPlayers)
          ]
    body = jsonBody jsonData
  in
    Debug.log (url model.host)
    request
     {  method = "PUT"
      , headers = []
      , url = url model.host
      , body = body
      , expect = expectJson Decoder.string
      , timeout = Nothing
      , withCredentials = False
     }

getIdAndIgn: Player -> (String, Value)
getIdAndIgn player = (player.ign, string player.id)
