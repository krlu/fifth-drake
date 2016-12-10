module Dashboard exposing (..)

import Array
import Controls.Controls as Controls
import GameModel exposing (Data, Metadata)
import Html.App
import Minimap.Minimap as Minimap
import Populate
import Subscriptions
import TagCarousel.TagCarousel as TagCarousel
import Types exposing (..)
import Update
import View
import Minimap.Minimap as Minimap
import TagCarousel.TagCarousel as TagCarousel
import TagForm.TagForm as TagForm


init : Flags -> (Model, Cmd Msg)
init flags =
  let
    minimapModel = Minimap.init flags.minimapBackground
    (tagCarouselModel, tagCarouselCmd) = TagCarousel.init flags.location
    (tagFormModel,tagFormCmd) = TagForm.init flags.location
    controlsModel = Controls.init flags
    metadata : Metadata
    metadata =
      { blueTeamName = ""
      , redTeamName = ""
      , gameLength = 100
      }
    data : Data
    data =
      { blueTeam =
        { teamStates = Array.empty
        , players = Array.empty
        }
      , redTeam =
        { teamStates = Array.empty
        , players = Array.empty
        }
      }
  in
    { minimap = minimapModel
    , tagCarousel = tagCarouselModel
    , tagForm = tagFormModel
    , controls = controlsModel
    , game =
      { metadata = metadata
      , data = data
      }
    , timestamp = 0
    } !
    [ Cmd.map TagCarouselMsg tagCarouselCmd
    , Populate.populate flags.location
    ]

main : Program Flags
main =
  Html.App.programWithFlags
    { init = init
    , view = View.view
    , update = Update.update
    , subscriptions = Subscriptions.subscriptions
    }
