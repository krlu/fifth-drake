module TagCarousel.Internal.Update exposing (..)

import GameModel exposing (Player, PlayerId, Timestamp)
import TagCarousel.Internal.TagUtils exposing (defaultTagForm)
import TagCarousel.Types exposing (Model, Msg(..), ShareData, Tag, TagFilter(..), TagForm, TagId)
import String as String exposing (toInt)
import TagCarousel.Internal.Delete as Delete
import TagCarousel.Internal.Save as Save
import TagCarousel.Internal.Share as Share

update : Msg -> Model -> Timestamp -> (Maybe Timestamp, Model, Cmd Msg)
update msg model ts =
  case msg of
    TagClick (timestamp, tagId) ->
      (Just timestamp, { model | lastClickedTag = tagId }, Cmd.none)
    UpdateTags (Ok tags) ->
      (Nothing, { model | tags = tags }, Cmd.none)
    UpdateTags (Err err) ->
      (Nothing, Debug.log "Tags failed to fetch!" model, Cmd.none)
    DeleteTag id ->
      (Nothing, model, Delete.sendRequest id model.host)
    EditTag tag ->
      let
        oldForm = model.tagForm
        newForm =
          { oldForm
          | title = tag.title
          , description = tag.description
          , selectedIds = tag.players
          , active = True
          , tagId = Just tag.id
          }
      in
      (Nothing, { model | tagForm = newForm }, Cmd.none)
    TagDeleted (Ok id)->
      (Nothing, { model | tags = filterTags model.tags id }, Cmd.none)
    TagDeleted (Err msg)->
      (Nothing, Debug.log "Could not delete tag!" model , Cmd.none)
    SwitchForm ->
      let
        oldForm = model.tagForm
      in
      (Nothing, { model | tagForm = switchTag oldForm } , Cmd.none)
    SaveTag ->
      let
        title = model.tagForm.title
        category = model.tagForm.category
        description = model.tagForm.description
        gameId = model.tagForm.gameId
        host = model.tagForm.host
      in
        if(String.length title == 0) then
          (Nothing, model, Cmd.none)
        else if(String.length category == 0) then
          (Nothing, model, Cmd.none)
        else if (String.length description == 0) then
          (Nothing, model, Cmd.none)
        else
          (Nothing, model, Save.sendRequest model.tagForm ts)
    TagSaved (Ok tags) ->
      let
        oldForm = model.tagForm
      in
      (Nothing, { model | tags = tags, tagForm = switchTag oldForm }, Cmd.none)
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
    ToggleShare tagId -> (Nothing, model, Share.sendRequest tagId model.host)
    ShareToggled (Ok shareData) ->
     let
      newTags = List.map (updateTag shareData) model.tags
     in
      (Nothing, {model | tags = newTags}, Cmd.none)
    ShareToggled (Err msg) -> (Nothing, Debug.log "could not toggle share!" model, Cmd.none)
    ToggleCarouselForm ->
      let
        newFormBool = not model.isShareForm
      in
      (Nothing, {model | isShareForm = newFormBool}, Cmd.none)
    ShowAllTags ->   (Nothing, {model | tagFilter = AllTags}, Cmd.none)
    ShowMyTags ->  (Nothing, {model | tagFilter = MyTags}, Cmd.none)
    UpdateGroupFilters groupId ->
      (Nothing, {model | tagFilter = GroupTags groupId}, Cmd.none)
    HighlightPlayers playerIds -> (Nothing, {model | highlightedPlayers = playerIds}, Cmd.none)
    UnhighlightPlayers -> (Nothing, {model | highlightedPlayers = []}, Cmd.none)
    ShowAutoTags -> (Nothing, {model| tagFilter = AutoTags}, Cmd.none)


filterTags: List Tag -> String -> List Tag
filterTags tags id =
  let
    customFilter: Tag -> Bool
    customFilter tag = tag.id /= id
  in
    List.filter customFilter tags

switchTag: TagForm -> TagForm
switchTag form =
  let
    oldActive = form.active
  in
    { form
    | active = not oldActive
    , selectedIds = []
    , title = ""
    , description = ""
    , category = "Objective"
    , tagId = Nothing
    }

updateTag: ShareData -> Tag -> Tag
updateTag shareData tag =
  case (tag.id == shareData.tagId, shareData.isShared) of
    (True, True) ->
      let
        newAuthorizedGroups = tag.authorizedGroups ++ [shareData.groupId]
      in
        {tag | authorizedGroups = newAuthorizedGroups}
    (True, False) ->
      let
        newAuthorizedGroups = List.filter (\groupId -> (groupId /= shareData.groupId)) tag.authorizedGroups
      in
        {tag | authorizedGroups = newAuthorizedGroups}
    (False, _) -> tag
