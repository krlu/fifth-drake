module TagCarousel.Internal.Save exposing (..)

import GameModel exposing (Player, Timestamp)
import Http exposing (Request, expectJson, jsonBody, request)
import Json.Decode as Decoder
import Json.Encode exposing (Value, int, list, object, string)
import String
import TagCarousel.Internal.Populate exposing (tag)
import TagCarousel.Types exposing (Msg(TagSaved), Tag, TagForm)

url : String -> String
url host = "http://" ++ host ++ "/saveTag"

sendRequest: TagForm -> Timestamp -> List Player -> Cmd Msg
sendRequest model ts players = Http.send TagSaved (createRequest model ts players)

createRequest: TagForm -> Timestamp -> List Player -> Request (List Tag)
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
    request
     {  method = "PUT"
      , headers = []
      , url = url model.host
      , body = body
      , expect = expectJson (Decoder.list tag)
      , timeout = Nothing
      , withCredentials = False
     }

getIdAndIgn: Player -> (String, Value)
getIdAndIgn player = (player.ign, string player.id)
