module Minimap.Minimap exposing (init, update, view, subscriptions)

import Html exposing (Html)
import Minimap.Internal.Populate as Populate
import Minimap.Internal.Update as Update
import Minimap.Internal.View as View
import Minimap.Types exposing (..)
import Types exposing (Location)

initialModel : String -> Model
initialModel background =
  { players = []
  , timestamp = 0
  , background = background
  }

init : String -> Location -> (Model, Cmd Msg)
init background loc = (initialModel background, Populate.populate loc)

update : Msg -> Model -> (Model, Cmd Msg)
update = Update.update

view : Model -> Html Msg
view = View.view

subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none
