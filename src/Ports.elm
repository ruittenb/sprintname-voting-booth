port module Ports
    exposing
        ( preloadImages
        , auth0showLock
        , auth0logout
        , onAuthenticationResult
        , onLoadPokedex
        , onLoadTeamRatings
        , onLoadUserRatings
        , saveUserRatings
        )

import Auth0
import Models.Pokemon exposing (PreloadCandidate)
import Models.Ratings exposing (UserRatings)
import Json.Encode exposing (Value)


port preloadImages : List PreloadCandidate -> Cmd msg


port auth0showLock : Auth0.Options -> Cmd msg


port auth0logout : () -> Cmd msg


port onAuthenticationResult : (Auth0.RawAuthenticationResult -> msg) -> Sub msg


port onLoadPokedex : (Value -> msg) -> Sub msg


port onLoadTeamRatings : (Value -> msg) -> Sub msg


port onLoadUserRatings : (Value -> msg) -> Sub msg


port saveUserRatings : UserRatings -> Cmd msg
