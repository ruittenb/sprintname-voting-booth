module Models exposing (..)

import Control
import Date exposing (Date)
import Models.Authentication exposing (AuthenticationModel)
import Models.Pages exposing (RemotePages)
import Models.Pokemon exposing (RemotePokedex)
import Models.Ratings exposing (RemoteTeamRatings)
import Models.Settings exposing (RemoteSettings)
import Models.Types exposing (..)
import Msgs exposing (Msg)
import Time exposing (Time)


type alias User =
    Maybe String


type alias ApplicationStateNoMessage =
    { authModel : AuthenticationModel
    , currentUser : User
    , highlightedUserId : Maybe Int
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
