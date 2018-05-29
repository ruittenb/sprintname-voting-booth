port module Ports
    exposing
        ( preloadImages
        , auth0showLock
        , auth0logout
        , saveUserRatings
        , onAuth0Result
        , onAuth0Logout
        , onLoadPokedex
        , onLoadTeamRatings
        , onLoadUserRatings
        )

import Auth0
import Models.Pokemon exposing (PortCompatiblePreloadCandidate)
import Models.Ratings exposing (UserRatings)
import Json.Encode exposing (Value)


-- Commands (outgoing)


port preloadImages : List PortCompatiblePreloadCandidate -> Cmd msg


port auth0showLock : Auth0.Options -> Cmd msg


port auth0logout : () -> Cmd msg


port saveUserRatings : UserRatings -> Cmd msg



-- Subscriptions (incoming)


port onAuth0Result : (Auth0.RawAuthenticationResult -> msg) -> Sub msg


port onAuth0Logout : (() -> msg) -> Sub msg


port onLoadPokedex : (Value -> msg) -> Sub msg


port onLoadTeamRatings : (Value -> msg) -> Sub msg


port onLoadUserRatings : (Value -> msg) -> Sub msg
