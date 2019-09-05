module Models exposing (..)

import Time exposing (Time)
import Models.Types exposing (..)
import Models.Authentication exposing (AuthenticationModel)
import Models.Settings exposing (RemoteSettings)
import Models.Pokemon exposing (RemotePokedex)
import Models.Pages exposing (RemotePages)
import Models.Ratings exposing (RemoteTeamRatings)
import Msgs exposing (Msg)
import Control


type alias LighthouseData =
    { name : String
    , caption : String
    }


type alias User =
    Maybe String


type alias PreloadedSets =
    { generations : List Int
    , letters : List Char
    }


type alias ApplicationStateNoMessage =
    { authModel : AuthenticationModel
    , currentUser : User
    , debounceState : Control.State Msg
    , currentRoute : Route
    , generation : Int
    , letter : Char
    , preloaded : PreloadedSets
    , query : String
    , settings : RemoteSettings
    , pokedex : RemotePokedex
    , pages : RemotePages
    , ratings : RemoteTeamRatings
    }


type alias StatusReporter x =
    { x
        | statusMessage : String
        , statusLevel : StatusLevel
        , statusExpiryTime : Maybe Time
    }


type alias ApplicationState =
    StatusReporter ApplicationStateNoMessage
