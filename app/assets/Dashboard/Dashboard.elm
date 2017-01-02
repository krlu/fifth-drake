module Dashboard exposing (..)

import Array
import Controls.Controls as Controls
import GameModel exposing (Data, Metadata)
import Minimap.Minimap as Minimap
import Navigation exposing (Location)
import Populate
import Subscriptions
import TagCarousel.TagCarousel as TagCarousel
import Types exposing (..)
import Update
import View
import Minimap.Minimap as Minimap
import TagCarousel.TagCarousel as TagCarousel


init : Flags -> Location -> (Model, Cmd Msg)
init flags location =
  let
    minimapModel = Minimap.init flags.minimapBackground
    (tagCarouselModel, tagCarouselCmd) = TagCarousel.init location flags.addTagButton
    controlsModel = Controls.init flags.playButton flags.pauseButton

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
    , controls = controlsModel
    , game =
      { metadata = metadata
      , data = data
      }
    , timestamp = 0
    } !
    [ Cmd.map TagCarouselMsg tagCarouselCmd
    , Populate.populate location
    ]

main : Program Flags Model Msg
main =
  Navigation.programWithFlags
    LocationUpdate
    { init = init
    , view = View.view
    , update = Update.update
    , subscriptions = Subscriptions.subscriptions
    }
