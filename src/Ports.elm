port module Ports exposing (preloadImages, auth0showLock, auth0authResult, auth0logout, onLoadPokedex)

import Auth0
import Models.Pokemon exposing (Pokedex, PreloadCandidate)
import Json.Encode exposing (Value)


port preloadImages : List PreloadCandidate -> Cmd msg


port auth0showLock : Auth0.Options -> Cmd msg


port auth0authResult : (Auth0.RawAuthenticationResult -> msg) -> Sub msg


port auth0logout : () -> Cmd msg


port onLoadPokedex : (Value -> msg) -> Sub msg
