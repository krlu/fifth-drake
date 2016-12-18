module TagForm.Internal.SaveTypes exposing (..)

import Http exposing (Body, Error, Response)
import TagCarousel.Types exposing (Tag)

type Msg
 = TagSaved (Result Http.Error Tag)
