module TagForm.TagForm exposing (..)

import GameModel exposing (Timestamp)
import Html exposing (Html)
import TagForm.Types exposing(..)
import TagForm.Internal.View as View
import TagForm.Internal.Update as Update
import Types exposing (WindowLocation)

init : WindowLocation -> (Model, Cmd Msg)
init loc =
  ( { title = ""
    , description = ""
    , category = ""
    , players = ""
    , gameId = loc.gameId
    , host = loc.host
    }
  , Cmd.none
  )

update : Msg -> Model -> Timestamp -> (Model, Cmd Msg)
update = Update.update

view : Model -> Html Msg
view = View.view

subscriptions : Sub Msg
subscriptions = Sub.none
