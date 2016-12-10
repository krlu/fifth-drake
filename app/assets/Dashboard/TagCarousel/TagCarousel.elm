module TagCarousel.TagCarousel exposing (init, update, view, subscriptions)

import GameModel exposing (Timestamp)
import Html exposing (Html)
import TagCarousel.Types exposing (..)
import TagCarousel.Internal.Populate as Populate
import TagCarousel.Internal.Update as Update
import TagCarousel.Internal.View as View
import Types exposing (WindowLocation)

init : WindowLocation -> (Model, Cmd Msg)
init loc = ({ tags = [] }, Populate.populate loc)

update : Msg -> Model -> (Maybe Timestamp, Model)
update = Update.update

view : Model -> Html Msg
view = View.view

subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none
