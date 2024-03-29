module Minimap.Types exposing (..)

import Animation
import Array exposing (..)
import Dict exposing (Dict)
import GameModel exposing (PlayerId, Side)
import PlaybackTypes exposing (..)
import SettingsTypes exposing (Icon)

type alias Model =
  { background : String
  -- the width and height of the map of the in game coordinates
  , mapWidth : Float
  , mapHeight : Float
  , iconStates : Dict PlayerId State
  , blueTowerIcon : Icon
  , redTowerIcon : Icon
  , towerKillIcon : Icon
  , blueInhibitorIcon : Icon
  , redInhibitorIcon : Icon
  , inhibitorKillIcon : Icon
  }

type Building = Tower | Inhibitor

type Msg
  = AnimatePlayerIcons Animation.Msg
  | GenerateIconStates
  | MoveIconStates Action

type alias State =
  { style : Animation.State
  , side : Side
  , img : String
  }
