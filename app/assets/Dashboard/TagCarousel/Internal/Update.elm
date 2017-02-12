module TagCarousel.Internal.Update exposing (..)

import GameModel exposing (Player, PlayerId, Timestamp)
import TagCarousel.Internal.TagUtils exposing (defaultTagForm)
import TagCarousel.Types exposing (Model, Msg(..), Tag, TagId)
import String as String exposing (toInt)
import TagCarousel.Internal.Delete as Delete
import TagCarousel.Internal.Save as Save

update : Msg -> Model -> Timestamp -> (Maybe Timestamp, Model, Cmd Msg)
update msg model ts =
  case msg of
    TagClick timestamp ->
      (Just timestamp, { model | lastClickedTime = timestamp }, Cmd.none)
    UpdateTags (Ok tags) ->
      (Nothing, { model | tags = tags }, Cmd.none)
    UpdateTags (Err err) ->
      (Nothing, Debug.log "Tags failed to fetch!" model, Cmd.none)
    DeleteTag id ->
      (Nothing, model, Delete.sendRequest id model.host)
    TagDeleted (Ok id)->
      (Nothing, { model | tags = filterTags model.tags id }, Cmd.none)
    TagDeleted (Err msg)->
      (Nothing, Debug.log "Could not delete tag!" model , Cmd.none)
    SwitchForm ->
      (Nothing, switchTag model , Cmd.none)
    SaveTag ->
      let
        title = model.tagForm.title
        category = model.tagForm.category
        description = model.tagForm.description
        gameId = model.tagForm.gameId
        host = model.tagForm.host
        modelWithEmptyTagform =
          { model
            | tagForm = defaultTagForm gameId host category
          }
      in
        if(String.length title == 0) then
          (Nothing, model, Cmd.none)
        else if(String.length category == 0) then
          (Nothing, model, Cmd.none)
        else if (String.length description == 0) then
          (Nothing, model, Cmd.none)
        else
          (Nothing, modelWithEmptyTagform, Save.sendRequest model.tagForm ts)
    TagSaved (Ok tags) ->
     (Nothing, switchTag { model | tags = tags }, Cmd.none)
    TagSaved (Err msg) ->
     (Nothing, Debug.log "Could not save tag!" model, Cmd.none)
    CreateTitle title ->
      let
        oldTagForm = model.tagForm
        newTagForm = { oldTagForm | title = title}
      in
        (Nothing, { model | tagForm = newTagForm }, Cmd.none)
    CreateDescription description ->
      let
        oldTagForm = model.tagForm
        newTagForm = { oldTagForm | description = description }
      in
        (Nothing, { model | tagForm = newTagForm }, Cmd.none)
    CreateCategory category ->
      let
        oldTagForm = model.tagForm
        newTagForm = { oldTagForm |  category = category }
      in
        (Nothing, { model | tagForm = newTagForm }, Cmd.none)
    AddPlayers id ->
      let
        oldTagForm = model.tagForm
        oldIdsList = oldTagForm.selectedIds
        newIdsList = if List.member id oldIdsList then
                       let
                         filter: PlayerId -> Bool
                         filter thisId = thisId /= id
                       in
                         List.filter filter oldIdsList
                     else
                       id :: oldIdsList
        newTagForm = { oldTagForm | selectedIds = newIdsList}
      in
        (Nothing, { model | tagForm = newTagForm }, Cmd.none)

filterTags: List Tag -> String -> List Tag
filterTags tags id =
  let
    customFilter: Tag -> Bool
    customFilter tag = tag.id /= id
  in
    List.filter customFilter tags

switchTag: Model -> Model
switchTag model =
  let
    oldTagForm = model.tagForm
    oldActive = model.tagForm.active
    newTagForm = { oldTagForm | active = not oldActive, selectedIds = [] }
  in
    { model | tagForm = newTagForm }
