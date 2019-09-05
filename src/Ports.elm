port module Ports
    exposing
        ( auth0ShowLock
        , auth0Logout
        , firebaseInit
        , firebaseLoginWithJwtToken
        , firebaseLoginWithFirebaseToken
        , firebaseLogout
        , preloadImages
        , saveUserRatings
        , onAuthenticationReceived
        , onAuthenticationFailed
        , onFirebaseLoginFailed
        , onLoadSettings
        , onLoadPokedex
        , onLoadPages
        , onLoadTeamRatings
        , onLoadUserRatings
        )

import Models.Auth exposing (LockParameters, Token)
import Models.Database exposing (FirebaseConfig, Diagnostics)
import Models.Pokemon exposing (PortCompatiblePreloadCandidate)
import Models.Ratings exposing (UserRatings)
import Json.Encode exposing (Value)


-- Commands (outgoing)


port auth0ShowLock : LockParameters -> Cmd msg


port auth0Logout : () -> Cmd msg


port firebaseInit : FirebaseConfig -> Cmd msg


port firebaseLoginWithJwtToken : Token -> Cmd msg


port firebaseLoginWithFirebaseToken : Token -> Cmd msg


port firebaseLogout : () -> Cmd msg


port preloadImages : List PortCompatiblePreloadCandidate -> Cmd msg


port saveUserRatings : UserRatings -> Cmd msg



-- Subscriptions (incoming)


port onAuthenticationReceived : (Value -> msg) -> Sub msg


port onAuthenticationFailed : (String -> msg) -> Sub msg


port onFirebaseLoginFailed : (Diagnostics -> msg) -> Sub msg


port onLoadSettings : (Value -> msg) -> Sub msg


port onLoadPokedex : (Value -> msg) -> Sub msg


port onLoadPages : (Value -> msg) -> Sub msg


port onLoadTeamRatings : (Value -> msg) -> Sub msg


port onLoadUserRatings : (Value -> msg) -> Sub msg
