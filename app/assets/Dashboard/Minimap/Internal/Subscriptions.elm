module Minimap.Internal.Subscriptions exposing (subscriptions)

import Animation exposing (subscription)
import Dict exposing (Dict)
import Minimap.Types exposing (Model, Msg(AnimatePlayerIcons))

subscriptions : Model -> Sub Msg
subscriptions model =
  Animation.subscription AnimatePlayerIcons <|
    List.map .style <| Dict.values model.iconStates
