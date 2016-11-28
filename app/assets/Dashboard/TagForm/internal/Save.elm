module TagForm.Internal.Save exposing (..)

import Http exposing (Body, RawError, Request, Response, defaultSettings, empty, multipart, stringData)
import String exposing (toInt)
import TagForm.Types exposing(Model)
import Task
import Types exposing (WindowLocation)

type Msg
 = TagSaved RawError
 | TagSaveFailure Response

url : WindowLocation -> String
url loc =  Http.url ("http://" ++ loc.host ++ "/saveTag") []

sendRequest: Model -> WindowLocation -> Cmd Msg
sendRequest model loc = Task.perform TagSaved TagSaveFailure <| Http.send defaultSettings (createRequest model loc)

createRequest: Model -> WindowLocation -> Request
createRequest model loc =
  let
    titleData = stringData "title" model.title
    descriptionData = stringData "description" model.description
    categoryData = stringData "category" model.category
    timestampData = stringData "timestamp" (toString model.timestamp)
    playerData = stringData "player" model.players
  in
   {  verb = "PUT"
    , headers = []
    , url = url loc
    , body = multipart [titleData, descriptionData, categoryData, timestampData, playerData]
   }
