module Minimap.Internal.Subscriptions exposing (subscriptions)

import Animation exposing (subscription)
import Dict exposing (Dict)
import Minimap.Types exposing (Model, Msg(AnimatePlayerIcon))

subscriptions : Model -> Sub Msg
subscriptions model =
  Animation.subscription AnimatePlayerIcon <|
      List.map .style <| Dict.values model.iconStates
