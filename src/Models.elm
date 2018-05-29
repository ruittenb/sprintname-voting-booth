module Models exposing (..)

import Models.Types exposing (..)
import Models.Pokemon exposing (RemotePokedex)
import Models.Ratings exposing (RemoteTeamRatings)
import Msgs exposing (Msg)
import Authentication
import Control exposing (State)


type alias LighthouseData =
    { name : String
    , caption : String
    }


type alias Subpage =
    { generation : Int
    , letter : Char
    }


type alias CurrentUser =
    Maybe String


type alias PreloadedSets =
    { generations : List Int
    , letters : List Char
    }


type alias ApplicationState =
    { authModel : Authentication.Model
    , user : CurrentUser
    , statusMessage : String
    , statusLevel : StatusLevel
    , debounceState : Control.State Msg
    , viewMode : ViewMode
    , generation : Int
    , letter : Char
    , preloaded : PreloadedSets
    , query : String
    , pokedex : RemotePokedex
    , ratings : RemoteTeamRatings
    }
