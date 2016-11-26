module TagForm.Internal.Update exposing (..)

import TagForm.Types exposing (..)
import Types exposing(Model)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Msg _ -> (model, Cmd.none)


update (NewContent content) oldContent =
  content
