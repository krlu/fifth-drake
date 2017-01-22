module Controls.Internal.Subscriptions exposing (subscriptions)

import Controls.Types exposing (Msg(..), Model)
import Mouse
import PlaybackTypes exposing (..)
import Time

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ case model.lastPosition of
        Nothing -> Sub.none
        Just _ -> Sub.batch
                    [ Mouse.moves KnobMove
                    , Mouse.ups KnobRelease
                    ]
    ]
