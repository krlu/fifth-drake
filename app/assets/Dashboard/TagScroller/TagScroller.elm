module TagScroller.TagScroller exposing (init, update, view, subscriptions)

import GameModel exposing (Timestamp)
import Html exposing (Html)
import TagScroller.Types exposing (..)
import TagScroller.Internal.Populate as Populate
import TagScroller.Internal.Update as Update
import TagScroller.Internal.View as View
import Types exposing (WindowLocation)

init : WindowLocation -> (Model, Cmd Msg)
init loc = ({ tags = [] }, Populate.populate loc)

update : Msg -> Model -> (Maybe Timestamp, Model)
update = Update.update

view : Model -> Html Msg
view = View.view

subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none

