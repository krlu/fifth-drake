module Subscriptions exposing (subscriptions)

import Messages exposing (Msg(..))
import Models exposing (Model)
import Mouse

subscriptions : Model -> Sub Msg
subscriptions model =
  case model.mouse of
    Nothing -> Sub.none
    Just _ -> Sub.batch [ Mouse.moves KnobMove, Mouse.ups KnobRelease ]
