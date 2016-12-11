module TagForm.Internal.SaveTypes exposing (..)

import Http exposing (Body, Error, Response)

type Msg
 = TagSaved (Result Http.Error String)
