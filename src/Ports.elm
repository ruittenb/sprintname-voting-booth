port module Ports
    exposing
        ( preloadImages
        , auth0ShowLock
        , auth0Logout
        , saveUserRatings
        , onAuthenticationReceived
        , onAuth0Logout
        , onLoadPokedex
        , onLoadTeamRatings
        , onLoadUserRatings
        )

import Models.Auth exposing (LockOptions)
import Models.Pokemon exposing (PreloadCandidate)
import Models.Ratings exposing (UserRatings)
import Json.Encode exposing (Value)


-- Commands (outgoing)


port auth0ShowLock : LockOptions -> Cmd msg


port firebaseLogin : LockOptions -> Cmd msg


port preloadImages : List PreloadCandidate -> Cmd msg


port auth0Logout : () -> Cmd msg


port saveUserRatings : UserRatings -> Cmd msg



-- Subscriptions (incoming)


port onAuthenticationReceived : (Value -> msg) -> Sub msg


port onAuth0Logout : (() -> msg) -> Sub msg


port onFirebaseLogin : (() -> msg) -> Sub msg


port onLoadPokedex : (Value -> msg) -> Sub msg


port onLoadTeamRatings : (Value -> msg) -> Sub msg


port onLoadUserRatings : (Value -> msg) -> Sub msg
