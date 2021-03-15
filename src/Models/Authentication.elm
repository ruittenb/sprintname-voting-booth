module Models.Authentication exposing (..)

import Constants.Authentication exposing (lockParameters)
import Models.Auth as Auth exposing (..)
import Msgs exposing (Msg)
import Ports exposing (auth0Logout, auth0ShowLock)


type AuthenticationState
    = LoggedOut
    | LoggedIn LoggedInUser


type alias AuthenticationModel =
    { state : AuthenticationState
    , lastError : Maybe AuthenticationError
    , lockParameters : LockParameters
    , showLock : LockParameters -> Cmd Msg
    , logOut : () -> Cmd Msg
    }


init : Maybe LoggedInUser -> AuthenticationModel
init initialData =
    let
        state =
            case initialData of
                Just user ->
                    LoggedIn user

                Nothing ->
                    LoggedOut
    in
    { state = state
    , lastError = Nothing
    , lockParameters = lockParameters
    , showLock = auth0ShowLock
    , logOut = auth0Logout
    }
