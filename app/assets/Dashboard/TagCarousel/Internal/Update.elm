module TagCarousel.Internal.Update exposing (..)

import GameModel exposing (Player, Timestamp)
import TagCarousel.Types exposing (Model, Msg(..), Tag)
import String as String
import TagCarousel.Internal.Delete as Delete
import TagCarousel.Internal.Save as Save

update : Msg -> Model -> Timestamp -> List Player -> (Maybe Timestamp, Model, Cmd Msg)
update msg model ts players =
  case msg of
    TagClick val ->
      (Just val, model, Cmd.none)
    UpdateTags (Ok tags) ->
      (Nothing, { model | tags = tags }, Cmd.none)
    UpdateTags (Err err) ->
      (Nothing, Debug.log "Tags failed to fetch" model, Cmd.none)
    DeleteTag id ->
      (Nothing, { model | tags = filterTags model.tags id }, Cmd.map SuccessOrFail (Delete.sendRequest id model.host))
    SuccessOrFail msg ->
      (Nothing, model, Cmd.none)
    CancelForm ->  -- TODO: should hide the form
     (Nothing, model, Cmd.none)
    SaveTag ->
     (Nothing, model, Save.sendRequest model.tagForm ts players)
    TagSaved (Ok tags) ->
     (Nothing, model, Cmd.none)
    TagSaved (Err tags) ->
     (Nothing, model, Cmd.none)
    CreateTitle title ->
      let
        oldTagForm = model.tagForm
        newTagForm = { oldTagForm | title = title}
      in
        (Nothing, {model | tagForm = newTagForm }, Cmd.none)
    CreateDescription description ->
      let
        oldTagForm = model.tagForm
        newTagForm = { oldTagForm | description = description}
      in
        (Nothing, {model | tagForm = newTagForm }, Cmd.none)
    CreateCategory category ->
      let
        oldTagForm = model.tagForm
        newTagForm = { oldTagForm |  category = category}
      in
        (Nothing, {model | tagForm = newTagForm }, Cmd.none)
    AddPlayers igns ->
      let
        oldTagForm = model.tagForm
        newTagForm = { oldTagForm |  players = igns}
      in
        (Nothing, {model | tagForm = newTagForm }, Cmd.none)


filterTags: List Tag -> String -> List Tag
filterTags tags id =
  let
    customFilter: Tag -> Bool
    customFilter tag = tag.id /= id
  in
    List.filter customFilter tags
