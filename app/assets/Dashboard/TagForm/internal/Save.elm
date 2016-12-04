module TagForm.Internal.Save exposing (..)

import Char exposing (isDigit)
import GameModel exposing (Timestamp)
import Http exposing (Request, defaultSettings, multipart, stringData)
import Regex exposing (HowMany(All), regex, replace)
import String exposing (trim)
import TagForm.Internal.SaveTypes exposing (Msg(TagSaveFailure, TagSaved))
import TagForm.Types exposing(Model)
import Task

url : String -> String
url host =  Http.url ("http://" ++ host ++ "/saveTag") []

sendRequest: Model -> Timestamp -> Cmd Msg
sendRequest model ts = Task.perform TagSaveFailure TagSaved
  <| Http.send defaultSettings (createRequest model ts)

createRequest: Model -> Timestamp -> Request
createRequest model ts =
  let
    gameId = stringData "gameKey" model.gameId
    titleData = stringData "title" model.title
    descriptionData = stringData "description" model.description
    categoryData = stringData "category" model.category
    timestampData = stringData "timestamp" (toString ts)
    playerData =  stringData "playerIgns" <| String.filter ((/=) ' ') model.players
      --TODO: add JSON encoder
  in
   {  verb = "PUT"
    , headers = []
    , url = url model.host
    , body = multipart [gameId, titleData, descriptionData, categoryData, timestampData, playerData]
   }
