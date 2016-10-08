module Timeline.Subscriptions exposing (subscriptions)

import Mouse
import Time
import Timeline.Messages exposing (Msg(..))
import Timeline.Models exposing (Model, Status(..))

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
