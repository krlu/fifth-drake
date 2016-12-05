module TagScroller.TagScroller exposing (init, update, view, subscriptions)

import GameModel exposing (GameId, Timestamp)
import Html exposing (Html)
import Navigation exposing (Location)
import TagScroller.Types exposing (..)
import TagScroller.Internal.Populate as Populate
import TagScroller.Internal.Update as Update
import TagScroller.Internal.View as View

init : String -> GameId -> (Model, Cmd Msg)
init host gameId = ({ tags = [] }, Populate.populate host gameId)

update : Msg -> Model -> (Maybe Timestamp, Model)
update = Update.update

view : Model -> Html Msg
view = View.view

subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none

