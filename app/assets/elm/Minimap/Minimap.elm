module Minimap.Minimap exposing (init, update, view, subscriptions)

import Html exposing (Html)
import Minimap.Internal.Populate as Populate
import Minimap.Internal.Update as Update
import Minimap.Internal.View as View
import Minimap.Types exposing (..)

initialModel : String -> Model
initialModel background =
  { players = []
  , timestamp = 0
  , background = background
  }

init : String -> (Model, Cmd Msg)
init background = (initialModel background, Populate.populate)

update : Msg -> Model -> (Model, Cmd Msg)
update = Update.update

view : Model -> Html Msg
view = View.view

subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none
