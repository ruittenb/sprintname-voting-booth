module Models exposing (..)

import Time exposing (Time)
import Date exposing (Date)
import Models.Types exposing (..)
import Models.Authentication exposing (AuthenticationModel)
import Models.Settings exposing (RemoteSettings)
import Models.Pokemon exposing (RemotePokedex)
import Models.Pages exposing (RemotePages)
import Models.Ratings exposing (RemoteTeamRatings)
import Msgs exposing (Msg)
import Control


type alias User =
    Maybe String


type alias ApplicationStateNoMessage =
    { authModel : AuthenticationModel
    , currentUser : User
    , currentRoute : Route
    , subPage : Maybe SubPage
    , query : String
    , todayDate : Maybe Date
    , settings : RemoteSettings
    , pokedex : RemotePokedex
    , pages : RemotePages
    , ratings : RemoteTeamRatings
    , debounceState : Control.State Msg
    }


type alias StatusReporter x =
    { x
        | statusMessage : String
        , statusLevel : StatusLevel
        , statusExpiryTime : Maybe Time
    }


type alias ApplicationState =
    StatusReporter ApplicationStateNoMessage
