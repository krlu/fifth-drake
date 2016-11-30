module TagForm.Internal.SaveTypes exposing (..)

import Http exposing (RawError, Response)

type Msg
 = TagSaved Response
 | TagSaveFailure RawError
