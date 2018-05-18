module Models.Authentication exposing (..)

import Models.Auth as Auth exposing (..)
import Msgs exposing (Msg)


type AuthenticationState
    = LoggedOut
    | LoggedIn LoggedInUser


type alias AuthenticationModel =
    { state : AuthenticationState
    , lastError : Maybe AuthenticationError
    , showLock : LockParameters -> Cmd Msg
    , lockParameters : LockParameters
    , logOut : () -> Cmd Msg
    }


init :
    (LockParameters -> Cmd Msg)
    -> (() -> Cmd Msg)
    -> LockParameters
    -> Maybe LoggedInUser
    -> AuthenticationModel
init showLock logOut lockParameters initialData =
    { state =
        case initialData of
            Just user ->
                LoggedIn user

            Nothing ->
                LoggedOut
    , lastError = Nothing
    , lockParameters = lockParameters
    , showLock = showLock
    , logOut = logOut
    }
