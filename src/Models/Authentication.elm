module Models.Authentication exposing (..)

import Models.Auth as Auth exposing (..)
import Msgs exposing (Msg)


type AuthenticationState
    = LoggedOut
    | LoggedIn LoggedInUser


type alias AuthenticationModel =
    { state : AuthenticationState
    , lastError : Maybe AuthenticationError
    , showLock : LockOptions -> Cmd Msg
    , auth0Options : LockOptions
    , logOut : () -> Cmd Msg
    }


init :
    (LockOptions -> Cmd Msg)
    -> (() -> Cmd Msg)
    -> LockOptions
    -> Maybe LoggedInUser
    -> AuthenticationModel
init showLock logOut lockOptions initialData =
    { state =
        case initialData of
            Just user ->
                LoggedIn user

            Nothing ->
                LoggedOut
    , lastError = Nothing
    , auth0Options = lockOptions
    , showLock = showLock
    , logOut = logOut
    }
