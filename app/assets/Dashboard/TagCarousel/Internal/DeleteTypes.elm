module TagCarousel.Internal.DeleteTypes exposing (..)
import Http exposing (Body, Error, Response)

type Msg
 = TagDeleted (Result Http.Error String)
