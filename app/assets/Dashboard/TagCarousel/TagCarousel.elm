module TagCarousel.TagCarousel exposing (init, update, view)

import GameModel exposing (GameId, Timestamp)
import Html exposing (Html)
import TagCarousel.Types exposing (..)
import TagCarousel.Internal.Populate as Populate
import TagCarousel.Internal.Update as Update
import TagCarousel.Internal.View as View
import Navigation exposing (Location)

init : Location -> (Model, Cmd Msg)
init loc = ({host = loc.host, tags = [] }, Populate.populate loc)

update : Msg -> Model -> (Maybe Timestamp, Model, Cmd Msg)
update = Update.update

view : Model -> Html Msg
view = View.view
