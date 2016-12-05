module TagScroller.TagScroller exposing (init, update, view, subscriptions)

import GameModel exposing (GameId, Timestamp)
import Html exposing (Html)
import Navigation exposing (Location)
import TagScroller.Types exposing (..)
import TagScroller.Internal.Populate as Populate
import TagScroller.Internal.Update as Update
import TagScroller.Internal.View as View

init : Location -> (Model, Cmd Msg)
init loc = ({ tags = [] }, Populate.populate loc)

update : Msg -> Model -> (Maybe Timestamp, Model)
update = Update.update

view : Model -> Html Msg
view = View.view

subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none

