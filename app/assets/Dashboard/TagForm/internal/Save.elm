module TagForm.Internal.Save exposing (..)

import Char exposing (isDigit)
import GameModel exposing (Timestamp)
import Http exposing (Request, expectString, multipartBody, request, stringPart)
import Regex exposing (HowMany(All), regex, replace)
import String exposing (trim)
import TagForm.Internal.SaveTypes exposing (Msg(TagSaved))
import TagForm.Types exposing(Model)

url : String -> String
url host = "http://" ++ host ++ "/saveTag"

sendRequest: Model -> Timestamp -> Cmd Msg
sendRequest model ts = Http.send TagSaved (createRequest model ts)

createRequest: Model -> Timestamp -> Request String
createRequest model ts =
  let
    gameId = stringPart "gameKey" (toString model.gameId)
    titleData = stringPart "title" model.title
    descriptionData = stringPart "description" model.description
    categoryData = stringPart "category" model.category
    timestampData = stringPart "timestamp" (toString ts)
    playerData =  stringPart "playerIgns" <| String.filter ((/=) ' ') model.players
      --TODO: add JSON encoder
  in
    request
     {  method = "PUT"
      , headers = []
      , url = url model.host
      , body = multipartBody [gameId, titleData, descriptionData, categoryData, timestampData, playerData]
      , expect = expectString
      , timeout = Nothing
      , withCredentials = False
     }
