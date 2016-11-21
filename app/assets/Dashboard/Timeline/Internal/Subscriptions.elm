module Timeline.Internal.Subscriptions exposing (subscriptions)

import Mouse
import Time
import Timeline.Types exposing (Msg(..), Model, Status(..))

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ case model.mouse of
        Nothing -> Sub.none
        Just _ -> Sub.batch
                    [ Mouse.moves KnobMove
                    , Mouse.ups KnobRelease
                    ]
    , case model.status of
        Pause -> Sub.none
        Play -> Time.every Time.second TimerUpdate
    ]
