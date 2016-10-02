module Timeline.Subscriptions exposing (subscriptions)

import Timeline.Messages exposing (Msg(..))
import Timeline.Models exposing (Model)
import Mouse

subscriptions : Model -> Sub Msg
subscriptions model =
  case model.mouse of
    Nothing -> Sub.none
    Just _ -> Sub.batch [ Mouse.moves KnobMove, Mouse.ups KnobRelease ]
