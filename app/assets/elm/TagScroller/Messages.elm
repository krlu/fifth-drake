module TagScroller.Messages exposing (..)

import Http
import TagScroller.Models exposing(Tag)
import Timeline.Models exposing (Value)

type Msg
  = TagClick Value
  | UpdateTags (List Tag)
  | TagFetchFailure Http.Error
