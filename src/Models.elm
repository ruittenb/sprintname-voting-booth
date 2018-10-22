module Models exposing (..)

import Models.Types exposing (..)
import Models.Authentication exposing (AuthenticationModel)
import Models.Pokemon exposing (RemotePokedex)
import Models.Ratings exposing (RemoteTeamRatings)
import Msgs exposing (Msg)
import Control exposing (State)


type alias LighthouseData =
    { name : String
    , caption : String
    }


type alias Subpage =
    { generation : Int
    , letter : Char
    }


type alias User =
    Maybe String


type alias PreloadedSets =
    { generations : List Int
    , letters : List Char
    }


type alias ApplicationState =
    { authModel : AuthenticationModel
    , currentUser : User
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
