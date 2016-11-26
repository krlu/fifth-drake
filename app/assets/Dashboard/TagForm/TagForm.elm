module TagForm.TagForm exposing (..)

import Html exposing (Html)
import Update
import TagForm.Types exposing(..)
import TagForm.Internal.View as View

--update : Msg -> Model -> (Model, Cmd Msg)
--update = Update.update

view : Model -> Html Msg
view = View.view

subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none
