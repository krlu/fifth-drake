module TagForm.Internal.Save exposing (..)

import Http exposing (Request, defaultSettings, multipart, stringData)
import TagForm.Internal.SaveTypes exposing (Msg(TagSaveFailure, TagSaved))
import TagForm.Types exposing(Model)
import Task

url : String -> String
url host =  Http.url ("http://" ++ host ++ "/saveTag") []

sendRequest: Model -> Cmd Msg
sendRequest model = Task.perform TagSaveFailure TagSaved
  <| Http.send defaultSettings (createRequest model)

createRequest: Model -> Request
createRequest model =
  let
    gameId = stringData "gameKey" model.gameId
    titleData = stringData "title" model.title
    descriptionData = stringData "description" model.description
    categoryData = stringData "category" model.category
    timestampData = stringData "timestamp" (toString model.timestamp)
    playerData = stringData "playerIgns" model.players --TODO: add JSON encoder
  in
   {  verb = "PUT"
    , headers = []
    , url = url model.host
    , body = multipart [gameId, titleData, descriptionData, categoryData, timestampData, playerData]
   }
